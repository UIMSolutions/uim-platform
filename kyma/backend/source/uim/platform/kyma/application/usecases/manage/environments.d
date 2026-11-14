/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.environments;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: Kyma runtime lifecycle. New runtimes start with the default
/// modules (istio, api-gateway, btp-operator); deleting a runtime cascades.
class ManageEnvironmentsUseCase
  : ResourceUseCase!(KymaEnvironment, KymaEnvironmentId, CreateEnvironmentRequest, UpdateEnvironmentRequest),
  IManageEnvironmentsUseCase {
  protected CascadeDeleter cascade;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, CascadeDeleter cascade) {
    super(repos, repos.environments, publisher, cluster, "Environment", "kyma.environment");
    this.cascade = cascade;
  }

  override protected KymaEnvironment build(CreateEnvironmentRequest r) {
    auto env = KymaEnvironment(r.tenantId);
    assignMatching(env, r.spec);
    env.status = EnvironmentStatus.provisioning;
    applyEnvironmentDefaults(env, nowStdTime());
    validateEnvironment(env);
    ensureState(repos.environments.findByName(r.tenantId, env.name).isNull,
      "An environment named '" ~ env.name ~ "' already exists");

    // default modules
    foreach (type; defaultModules) {
      auto mod = KymaModule(r.tenantId);
      mod.environmentId = env.id;
      mod.moduleType = type;
      mod.name = enumText(type);
      mod.version_ = defaultVersionOf(type, ModuleChannel.regular);
      mod.requiredModules = dependenciesOf(type).map!(t => enumText(t)).array;
      mod.status = ModuleStatus.installing;
      mod.createdBy = r.actor;
      mod.updatedBy = r.actor;
      repos.modules.save(mod);
    }
    return env;
  }

  override protected void apply(ref KymaEnvironment env, EnvironmentSpec spec) {
    ensureState(env.status != EnvironmentStatus.stopped && env.status != EnvironmentStatus.stopping,
      "Start the environment before changing it");
    // name, plan, region and subaccount cannot be changed after provisioning
    assignMatching(env, spec, ["name", "plan", "region", "subaccountId"]);
    if (spec.autoScalerMin <= 0)
      env.autoScalerMin = limitsOf(env.plan).minNodes;
    if (spec.autoScalerMax <= 0)
      env.autoScalerMax = max(env.autoScalerMin, limitsOf(env.plan).maxNodes == 1 ? 1 : 20);
    validateEnvironment(env);
    if (env.status == EnvironmentStatus.running)
      env.status = EnvironmentStatus.updating;
  }

  override protected Json render(KymaEnvironment env) {
    return toManifest(env, repos.modules.findByEnvironment(env.tenantId, env.id));
  }

  override protected void beforeRemove(KymaEnvironment env) {
    cascade.clearEnvironment(env.tenantId, env.id);
  }

  UsecaseResult stop(TenantId tenantId, KymaEnvironmentId id, UserId actor) {
    return transition(tenantId, id, actor, "stopped", (ref KymaEnvironment env) {
      ensureState(env.status == EnvironmentStatus.running,
        "Only a running environment can be stopped (status: " ~ enumText(env.status) ~ ")");
      env.status = EnvironmentStatus.stopping;
    });
  }

  UsecaseResult start(TenantId tenantId, KymaEnvironmentId id, UserId actor) {
    return transition(tenantId, id, actor, "started", (ref KymaEnvironment env) {
      ensureState(env.status == EnvironmentStatus.stopped,
        "Only a stopped environment can be started (status: " ~ enumText(env.status) ~ ")");
      env.status = EnvironmentStatus.updating;
    });
  }
}
