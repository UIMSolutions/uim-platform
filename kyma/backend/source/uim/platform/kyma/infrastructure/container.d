/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.container;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  KymaConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  KymaRepositories repositories;
  IKymaEventPublisher publisher;
  RecordingClusterGateway cluster;

  // ── Driving ports ─────────────────────────────────────────────────────
  KymaPorts ports;

  this(KymaConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage)
      storage = new JsonFileSnapshotStorage(config.dataDir);

    auto store(TEntity, TId, TMapper)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, TMapper)(storage, collection);
      return s;
    }

    with (repositories) {
      environments = new EnvironmentRepository(
        store!(KymaEnvironment, KymaEnvironmentId, EnvironmentMapper)(KymaCollections.environments));
      namespaces = new NamespaceRepository(
        store!(KymaNamespace, NamespaceId, NamespaceMapper)(KymaCollections.namespaces));
      functions = new FunctionRepository(
        store!(ServerlessFunction, ServerlessFunctionId, FunctionMapper)(KymaCollections.functions));
      apiRules = new ApiRuleRepository(
        store!(ApiRule, ApiRuleId, ApiRuleMapper)(KymaCollections.apiRules));
      serviceInstances = new ServiceInstanceRepository(
        store!(ServiceInstance, ServiceInstanceId, ServiceInstanceMapper)(KymaCollections.serviceInstances));
      serviceBindings = new ServiceBindingRepository(
        store!(ServiceBinding, ServiceBindingId, ServiceBindingMapper)(KymaCollections.serviceBindings));
      subscriptions = new EventSubscriptionRepository(
        store!(EventSubscription, EventSubscriptionId, EventSubscriptionMapper)(KymaCollections.subscriptions));
      modules = new ModuleRepository(
        store!(KymaModule, KymaModuleId, ModuleMapper)(KymaCollections.modules));
      applications = new ApplicationRepository(
        store!(KymaApplication, ApplicationId, ApplicationMapper)(KymaCollections.applications));
    }
    publisher = new LogEventPublisher();
    cluster = new RecordingClusterGateway();
  }

  protected void wireApplication() {
    auto r = repositories;
    auto cascade = new CascadeDeleter(r);

    ports.environments = new ManageEnvironmentsUseCase(r, publisher, cluster, cascade);
    ports.namespaces = new ManageNamespacesUseCase(r, publisher, cluster, cascade);
    ports.functions = new ManageFunctionsUseCase(r, publisher, cluster, new FunctionValidator());
    ports.apiRules = new ManageApiRulesUseCase(r, publisher, cluster, new ApiRuleValidator());
    ports.serviceInstances = new ManageServiceInstancesUseCase(r, publisher, cluster);
    ports.serviceBindings = new ManageServiceBindingsUseCase(r, publisher, cluster);
    ports.subscriptions = new ManageEventSubscriptionsUseCase(r, publisher, cluster, new SubscriptionPolicy());
    ports.modules = new ManageModulesUseCase(r, publisher, cluster, new ModuleDependencyResolver());
    ports.applications = new ManageApplicationsUseCase(r, publisher, cluster);
    ports.reconciler = new ReconcileUseCase(r, cascade, publisher);
    ports.statistics = new KymaStatisticsService(r);
  }
}

/// Build the full dependency graph.
Container buildContainer(KymaConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  KymaConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");

  // provision a runtime → default modules are installing
  CreateEnvironmentRequest env;
  env.tenantId = t;
  env.actor = who;
  env.spec.name = "dev";
  env.spec.plan = KymaPlan.azure;
  auto created = p.environments.create(env);
  assert(created.isSuccess, created.message);
  auto envId = KymaEnvironmentId(created.id);
  assert(p.modules.list(t).length == 3);
  assert(p.modules.list(t).any!(m => m.name == "api-gateway" && m.requiredModules == ["istio"]));

  // namespace
  CreateNamespaceRequest ns;
  ns.tenantId = t;
  ns.parentId = envId;
  ns.spec.name = "shop";
  auto nsResult = p.namespaces.create(ns);
  assert(nsResult.isSuccess, nsResult.message);
  auto nsId = NamespaceId(nsResult.id);

  // a function needs the serverless module
  CreateFunctionRequest fn;
  fn.tenantId = t;
  fn.parentId = nsId;
  fn.spec.name = "hello";
  fn.spec.sourceCode = "module.exports = { main: () => 'hi' }";
  auto denied = p.functions.create(fn);
  assert(!denied.isSuccess && denied.code == 409);

  EnableModuleRequest serverless;
  serverless.tenantId = t;
  serverless.parentId = envId;
  serverless.spec.moduleType = ModuleType.serverless;
  assert(p.modules.create(serverless).isSuccess);
  auto fnResult = p.functions.create(fn);
  assert(fnResult.isSuccess, fnResult.message);

  // duplicate name → conflict, bad name → validation
  assert(p.functions.create(fn).code == 409);
  fn.spec.name = "Bad_Name";
  assert(p.functions.create(fn).code == 422);

  // reconcile: environment runs, modules enable, function builds → deploys → runs
  auto first = p.reconciler.reconcile(t);
  assert(first.advanced > 0);
  p.reconciler.reconcile(t);
  p.reconciler.reconcile(t);
  assert(p.functions.get(t, ServerlessFunctionId(fnResult.id)).status == FunctionStatus.running);
  assert(p.environments.get(t, envId).status == EnvironmentStatus.running);

  // manifests
  assert(p.functions.manifest(t, ServerlessFunctionId(fnResult.id))["kind"].get!string == "Function");
  assert(c.cluster.operations.length > 0);

  // service instance + binding; instance with bindings cannot be deleted
  CreateServiceInstanceRequest si;
  si.tenantId = t;
  si.parentId = nsId;
  si.spec.name = "xsuaa";
  si.spec.serviceOfferingName = "xsuaa";
  si.spec.servicePlanName = "application";
  auto siResult = p.serviceInstances.create(si);
  assert(siResult.isSuccess, siResult.message);
  CreateServiceBindingRequest sb;
  sb.tenantId = t;
  sb.parentId = ServiceInstanceId(siResult.id);
  sb.spec.name = "xsuaa-binding";
  assert(p.serviceBindings.create(sb).isSuccess);
  assert(p.serviceInstances.remove(t, ServiceInstanceId(siResult.id), who).code == 409);
  p.reconciler.reconcile(t);
  assert(p.serviceBindings.list(t)[0].status == ServiceBindingStatus.ready);
  assert(p.serviceInstances.get(t, ServiceInstanceId(siResult.id)).bindingCount == 1);

  // serverless cannot be disabled while functions exist
  auto serverlessId = p.modules.list(t).filter!(m => m.moduleType == ModuleType.serverless).front.id;
  assert(p.modules.disable(t, serverlessId, who).code == 409);

  // statistics
  auto stats = p.statistics.statistics(t);
  assert(stats.environments == 1 && stats.functionsRunning == 1 && stats.serviceBindings == 1);

  // deleting the runtime cascades
  assert(p.environments.remove(t, envId, who).isSuccess);
  assert(p.namespaces.list(t).length == 0 && p.functions.list(t).length == 0 && p.modules.list(t).length == 0);
}
