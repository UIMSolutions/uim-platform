/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.modules;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.ports.repositories.modules;
// import uim.platform.kyma.domain.services.module_dependency_resolver;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kyma module management.
class ManageModulesUseCase : UIMUseCase {
  private ModuleRepository moduleRepository;
  private ModuleDependencyResolver depResolver;

  this(ModuleRepository moduleRepository, ModuleDependencyResolver depResolver) {
    this.moduleRepository = moduleRepository;
    this.depResolver = depResolver;
  }

  CommandResult enableModule(EnableModuleRequest request) {
    if (request.name.length == 0)
      return CommandResult(false, "", "Module name is required");

    if (request.environmentId.isEmpty)
      return CommandResult(false, "", "Environment ID is required");

    auto existing = moduleRepository.findByName(request.environmentId, request.name);
    if (existing.id.length > 0 && existing.status == ModuleStatus.enabled)
      return CommandResult(false, "", "Module '" ~ request.name ~ "' is already enabled");

    // import std.uuid : randomUUID;
    auto id = existing.id.length > 0 ? existing.id : randomUUID().toString();

    KymaModule mod;
    mod.moduleId = id;
    mod.environmentId = request.environmentId;
    mod.tenantId = request.tenantId;
    mod.name = request.name;
    mod.moduleType = toModuleType(request.moduleType);
    mod.version_ = request.version_;
    mod.channel = request.channel.length > 0 ? request.channel : "regular";
    mod.customResourcePolicy = request.customResourcePolicy;
    mod.configurationJson = request.configurationJson;
    mod.status = ModuleStatus.installing;
    mod.enabledBy = request.enabledBy;
    mod.enabledAt = clockSeconds();
    mod.modifiedAt = mod.enabledAt;

    // Set known dependencies
    mod.requiredModules = getKnownDependencies(mod.moduleType);

    // Check dependencies
    auto allModules = moduleRepository.findByEnvironment(request.environmentId);
    if (!depResolver.canEnable(mod, allModules)) {
      auto missing = depResolver.getUnsatisfiedDependencies(mod, allModules);
      // import std.array : join;
      return CommandResult(false, "", "Missing required modules: " ~ missing.join(", "));
    }

    if (!existing.id.isEmpty)
      moduleRepository.update(mod);
    else
      moduleRepository.save(mod);
    return CommandResult(true, id.toString, "");
  }

  CommandResult disableModule(KymaModuleId moduleId) {
    if (!moduleRepository.existsById(moduleId))
      return CommandResult(false, "", "Module not found");

    auto mod = moduleRepository.findById(moduleId);
    if (mod.status == ModuleStatus.disabled)
      return CommandResult(false, "", "Module is already disabled");

    // Check for dependents
    auto allModules = moduleRepository.findByEnvironment(mod.environmentId);
    auto dependents = depResolver.findDependents(mod.name, allModules);
    if (dependents.length > 0) {
      // import std.array : join;
      return CommandResult(false, "",
        "Cannot disable: modules depend on it: " ~ dependents.join(", "));
    }

    mod.status = ModuleStatus.uninstalling;
    mod.modifiedAt = clockSeconds();
    moduleRepository.update(mod);
    return CommandResult(true, moduleId.toString, "");
  }

  CommandResult updateModule(KymaModuleId moduleId, UpdateModuleRequest request) {
    if (!moduleRepository.existsById(moduleId))
      return CommandResult(false, "", "Module not found");

    auto mod = moduleRepository.findById(moduleId);
    if (request.version_.length > 0)
      mod.version_ = request.version_;
    if (request.channel.length > 0)
      mod.channel = request.channel;
    if (request.customResourcePolicy.length > 0)
      mod.customResourcePolicy = request.customResourcePolicy;
    if (request.configurationJson.length > 0)
      mod.configurationJson = request.configurationJson;
    mod.modifiedAt = clockSeconds();

    moduleRepository.update(mod);
    return CommandResult(true, moduleId.toString, "");
  }

  KymaModule getModule(KymaModuleId moduleId) {
    return moduleRepository.findById(moduleId);
  }

  KymaModule[] listByEnvironment(KymaEnvironmentId environmentId) {
    return moduleRepository.findByEnvironment(environmentId);
  }

  CommandResult deleteModule(KymaModuleId moduleId) {
    if (!moduleRepository.existsById(moduleId))
      return CommandResult(false, "", "Module not found");

    moduleRepository.remove(moduleId);
    return CommandResult(true, moduleId.toString, "");
  }

  private string[] getKnownDependencies(ModuleType type) {
    switch (type) {
    case ModuleType.apiGateway:
      return ["istio"];
    case ModuleType.serverless:
      return [];
    case ModuleType.eventing:
      return ["nats"];
    case ModuleType.keda:
      return [];
    case ModuleType.connectivityProxy:
      return ["istio"];
    default:
      return [];
    }
  }
}
