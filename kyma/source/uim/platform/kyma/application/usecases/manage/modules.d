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

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kyma module management.
class ManageModulesUseCase {
  protected ModuleRepository moduleRepository;
  private ModuleDependencyResolver depResolver;

  this(ModuleRepository moduleRepository, ModuleDependencyResolver depResolver) {
    this.moduleRepository = moduleRepository;
    this.depResolver = depResolver;
  }

  UsecaseResult enableModule(EnableModuleRequest request) {
    if (request.name.isEmpty)
      return UsecaseResult(false, "", "Module name is required");

    if (request.environmentId.isEmpty)
      return UsecaseResult(false, "", "Environment ID is required");

    auto existing = moduleRepository.findByName(request.tenantId, request.environmentId, request.name);
    if (existing.id.value.length > 0 && existing.status == ModuleStatus
      .enabled)
      return UsecaseResult(false, "", "Module '" ~ request.name ~ "' is already enabled");

    KymaModule mod;
    with (mod) {
      id = existing.id.value.length > 0 ? existing.id.value : generateId;
      environmentId = request.environmentId;
      tenantId = request.tenantId;
      name = request.name;
      moduleType = toModuleType(request.moduleType);
      version_ = request.version_;
      channel = request.channel.length > 0 ? request.channel : "regular";
      customResourcePolicy = request.customResourcePolicy;
      configurationJson = request.configurationJson;
      status = ModuleStatus.installing;
      enabledBy = request.enabledBy;
      enabledAt = clockSeconds();
      updatedAt = enabledAt;
    }
    // Set known dependencies
    mod.requiredModules = getKnownDependencies(mod.moduleType);

    // Check dependencies
    auto allModules = moduleRepository.findByEnvironment(request.tenantId, request.environmentId);
    if (!depResolver.canEnable(mod, allModules)) {
      auto missing = depResolver.getUnsatisfiedDependencies(mod, allModules);
      // import std.array : join;
      return UsecaseResult(false, "", "Missing required modules: " ~ missing.join(", "));
    }

    if (!existing.isNull)
      moduleRepository.update(mod);
    else
      moduleRepository.save(mod);
    return UsecaseResult(true, mod.id.value, "");
  }

  UsecaseResult disableModule(TenantId tenantId, KymaModuleId moduleId) {
    if (!moduleRepository.existsById(tenantId, moduleId))
      return UsecaseResult(false, "", "Module not found");

    auto mod = moduleRepository.findById(tenantId, moduleId);
    if (mod.status == ModuleStatus.disabled)
      return UsecaseResult(false, "", "Module is already disabled");

    // Check for dependents
    auto allModules = moduleRepository.findByEnvironment(tenantId, mod.environmentId);
    auto dependents = depResolver.findDependents(mod.name, allModules);
    if (dependents.length > 0) {
      // import std.array : join;
      return UsecaseResult(false, "",
        "Cannot disable: modules depend on it: " ~ dependents.join(", "));
    }

    mod.status = ModuleStatus.uninstalling;
    mod.updatedAt = clockSeconds();
    moduleRepository.update(mod);
    return UsecaseResult(true, mod.id.value, "");
  }

  UsecaseResult updateModule(UpdateModuleRequest request) {
    auto mod = moduleRepository.findById(request.tenantId, request.moduleId);
    if (mod.isNull)
      return UsecaseResult(false, "", "Module not found");

    if (request.version_.length > 0)
      mod.version_ = request.version_;
    if (request.channel.length > 0)
      mod.channel = request.channel;
    if (request.customResourcePolicy.length > 0)
      mod.customResourcePolicy = request.customResourcePolicy;
    if (request.configurationJson.length > 0)
      mod.configurationJson = request.configurationJson;
    mod.updatedAt = clockSeconds();

    moduleRepository.update(mod);
    return UsecaseResult(true, mod.id.value, "");
  }

  bool hasModule(TenantId tenantId, KymaModuleId moduleId) {
    return moduleRepository.existsById(tenantId, moduleId);
  }

  KymaModule getModule(TenantId tenantId, KymaModuleId moduleId) {
    return moduleRepository.findById(tenantId, moduleId);
  }

  KymaModule[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return moduleRepository.findByEnvironment(tenantId, environmentId);
  }

  UsecaseResult deleteModule(TenantId tenantId, KymaModuleId moduleId) {
    auto mod = moduleRepository.findById(tenantId, moduleId);
    if (mod.isNull)
      return UsecaseResult(false, "", "Module not found");

    moduleRepository.remove(mod);
    return UsecaseResult(true, mod.id.value, "");
  }
}
