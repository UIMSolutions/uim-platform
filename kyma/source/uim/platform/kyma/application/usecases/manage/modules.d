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
  private ModuleRepository repo;
  private ModuleDependencyResolver depResolver;

  this(ModuleRepository repo, ModuleDependencyResolver depResolver) {
    this.repo = repo;
    this.depResolver = depResolver;
  }

  CommandResult enableModule(EnableModuleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Module name is required");
    if (req.environmentId.length == 0)
      return CommandResult(false, "", "Environment ID is required");

    auto existing = repo.findByName(req.environmentId, req.name);
    if (existing.id.length > 0 && existing.status == ModuleStatus.enabled)
      return CommandResult(false, "", "Module '" ~ req.name ~ "' is already enabled");

    // import std.uuid : randomUUID;
    auto id = existing.id.length > 0 ? existing.id : randomUUID().toString();

    KymaModule mod;
    mod.id = id;
    mod.environmentId = req.environmentId;
    mod.tenantId = req.tenantId;
    mod.name = req.name;
    mod.moduleType = parseModuleType(req.moduleType);
    mod.version_ = req.version_;
    mod.channel = req.channel.length > 0 ? req.channel : "regular";
    mod.customResourcePolicy = req.customResourcePolicy;
    mod.configurationJson = req.configurationJson;
    mod.status = ModuleStatus.installing;
    mod.enabledBy = req.enabledBy;
    mod.enabledAt = clockSeconds();
    mod.modifiedAt = mod.enabledAt;

    // Set known dependencies
    mod.requiredModules = getKnownDependencies(mod.moduleType);

    // Check dependencies
    auto allModules = repo.findByEnvironment(req.environmentId);
    if (!depResolver.canEnable(mod, allModules)) {
      auto missing = depResolver.getUnsatisfiedDependencies(mod, allModules);
      // import std.array : join;
      return CommandResult(false, "", "Missing required modules: " ~ missing.join(", "));
    }

    if (existing.id.length > 0)
      repo.update(mod);
    else
      repo.save(mod);
    return CommandResult(true, id, "");
  }

  CommandResult disableModule(ModuleId id) {
    auto mod = repo.findById(id);
    if (mod.id.length == 0)
      return CommandResult(false, "", "Module not found");
    if (mod.status == ModuleStatus.disabled)
      return CommandResult(false, "", "Module is already disabled");

    // Check for dependents
    auto allModules = repo.findByEnvironment(mod.environmentId);
    auto dependents = depResolver.findDependents(mod.name, allModules);
    if (dependents.length > 0) {
      // import std.array : join;
      return CommandResult(false, "",
          "Cannot disable: modules depend on it: " ~ dependents.join(", "));
    }

    mod.status = ModuleStatus.uninstalling;
    mod.modifiedAt = clockSeconds();
    repo.update(mod);
    return CommandResult(true, id, "");
  }

  CommandResult updateModule(ModuleId id, UpdateModuleRequest req) {
    auto mod = repo.findById(id);
    if (mod.id.length == 0)
      return CommandResult(false, "", "Module not found");

    if (req.version_.length > 0)
      mod.version_ = req.version_;
    if (req.channel.length > 0)
      mod.channel = req.channel;
    if (req.customResourcePolicy.length > 0)
      mod.customResourcePolicy = req.customResourcePolicy;
    if (req.configurationJson.length > 0)
      mod.configurationJson = req.configurationJson;
    mod.modifiedAt = clockSeconds();

    repo.update(mod);
    return CommandResult(true, id, "");
  }

  KymaModule getModule(ModuleId id) {
    return repo.findById(id);
  }

  KymaModule[] listByEnvironment(KymaEnvironmentId envId) {
    return repo.findByEnvironment(envId);
  }

  CommandResult deleteModule(ModuleId id) {
    auto mod = repo.findById(id);
    if (mod.id.length == 0)
      return CommandResult(false, "", "Module not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private ModuleType parseModuleType(string s) {
    switch (s) {
    case "istio":
      return ModuleType.istio;
    case "api-gateway":
      return ModuleType.apiGateway;
    case "serverless":
      return ModuleType.serverless;
    case "eventing":
      return ModuleType.eventing;
    case "nats":
      return ModuleType.nats;
    case "telemetry":
      return ModuleType.telemetry;
    case "btp-operator":
      return ModuleType.btp_operator;
    case "keda":
      return ModuleType.keda;
    case "connectivity-proxy":
      return ModuleType.connectivityProxy;
    default:
      return ModuleType.custom;
    }
  }

  private string[] getKnownDependencies(ModuleType t) {
    switch (t) {
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

private long clockSeconds() {
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
