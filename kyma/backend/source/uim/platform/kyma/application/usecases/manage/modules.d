/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.modules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: Kyma modules. Enabling checks dependencies, disabling checks
/// dependent modules and workloads that still need the module.
class ManageModulesUseCase
  : ResourceUseCase!(KymaModule, KymaModuleId, EnableModuleRequest, UpdateModuleRequest),
  IManageModulesUseCase {
  protected ModuleDependencyResolver resolver;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, ModuleDependencyResolver resolver) {
    super(repos, repos.modules, publisher, cluster, "Module", "kyma.module");
    this.resolver = resolver;
  }

  /// Enabling a module that exists but is disabled re-enables it (same id).
  override UsecaseResult create(EnableModuleRequest r) {
    auto name = r.spec.moduleType == ModuleType.custom ? r.spec.name : enumText(r.spec.moduleType);
    auto existing = repos.modules.findByName(r.tenantId, r.parentId, name);
    if (!existing.isNull && !existing.status.isActive) {
      UpdateModuleRequest u;
      u.tenantId = r.tenantId;
      u.actor = r.actor;
      u.id = existing.id;
      u.spec = r.spec;
      auto updated = update(u);
      return updated.isSuccess ? enable(r.tenantId, existing.id, r.actor) : updated;
    }
    return super.create(r);
  }

  override protected KymaModule build(EnableModuleRequest r) {
    auto env = requireEnvironment(r.tenantId, r.parentId);
    auto mod = KymaModule(r.tenantId);
    mod.environmentId = env.id;
    assignMatching(mod, r.spec);
    if (mod.moduleType != ModuleType.custom)
      mod.name = enumText(mod.moduleType);
    validateResourceName("Module", mod.name);
    ensureState(repos.modules.findByName(r.tenantId, env.id, mod.name).isNull,
      "Module '" ~ mod.name ~ "' is already enabled in environment '" ~ env.name ~ "'");
    normalize(mod);
    checkDependencies(mod);
    mod.status = ModuleStatus.installing;
    return mod;
  }

  override protected void apply(ref KymaModule mod, ModuleSpec spec) {
    assignMatching(mod, spec, ["name", "moduleType"]);
    normalize(mod);
  }

  protected void normalize(ref KymaModule mod) {
    if (mod.version_.length == 0)
      mod.version_ = defaultVersionOf(mod.moduleType, mod.channel);
    mod.requiredModules = dependenciesOf(mod.moduleType).map!(t => enumText(t)).array;
    validate(mod.customResourcePolicy == "CreateAndDelete" || mod.customResourcePolicy == "Ignore",
      "customResourcePolicy must be CreateAndDelete or Ignore");
    validateJsonObject("configurationJson", mod.configurationJson);
  }

  protected void checkDependencies(const ref KymaModule mod) {
    auto missing = resolver.missingDependencies(mod, repos.modules.findByEnvironment(mod.tenantId, mod.environmentId));
    ensureState(missing.length == 0, "Module '" ~ mod.name ~ "' requires: " ~ missing.join(", ") ~ " — enable them first");
  }

  protected void checkUnused(const ref KymaModule mod) {
    auto installed = repos.modules.findByEnvironment(mod.tenantId, mod.environmentId);
    auto dependents = resolver.dependents(mod.name, installed);
    ensureState(dependents.length == 0, "Cannot disable '" ~ mod.name ~ "': required by " ~ dependents.join(", "));

    size_t workloads;
    auto t = mod.tenantId, e = mod.environmentId;
    switch (mod.moduleType) {
    case ModuleType.serverless:
      workloads = repos.functions.findByEnvironment(t, e).length;
      break;
    case ModuleType.apiGateway:
      workloads = repos.apiRules.findByEnvironment(t, e).length;
      break;
    case ModuleType.eventing:
      workloads = repos.subscriptions.findByEnvironment(t, e).length;
      break;
    case ModuleType.btpOperator:
      workloads = repos.serviceInstances.findByEnvironment(t, e).length;
      break;
    case ModuleType.applicationConnector:
      workloads = repos.applications.findByEnvironment(t, e).length;
      break;
    default:
      break;
    }
    ensureState(workloads == 0, "Cannot disable '" ~ mod.name ~ "': " ~ workloads.to!string
        ~ " resource(s) in the environment still use it");
  }

  override protected void beforeRemove(KymaModule mod) {
    ensureState(!mod.status.isActive, "Disable module '" ~ mod.name ~ "' before deleting it");
  }

  override protected Json render(KymaModule mod) {
    return Json(null); // modules are part of the environment's Kyma CR
  }

  UsecaseResult disable(TenantId tenantId, KymaModuleId id, UserId actor) {
    return transition(tenantId, id, actor, "disabled", (ref KymaModule mod) {
      ensureState(mod.status.isActive, "Module '" ~ mod.name ~ "' is not enabled");
      checkUnused(mod);
      mod.status = ModuleStatus.uninstalling;
    });
  }

  UsecaseResult enable(TenantId tenantId, KymaModuleId id, UserId actor) {
    return transition(tenantId, id, actor, "enabled", (ref KymaModule mod) {
      ensureState(!mod.status.isActive, "Module '" ~ mod.name ~ "' is already enabled");
      checkDependencies(mod);
      mod.status = ModuleStatus.installing;
    });
  }

  override protected void synchronize(KymaModule mod, string verb) {
    // re-render the Kyma CR of the environment
    auto env = repos.environments.findById(mod.tenantId, mod.environmentId);
    if (!env.isNull)
      cluster.apply(env.id, toManifest(env, repos.modules.findByEnvironment(env.tenantId, env.id)));
    publish(mod, verb);
  }
}
