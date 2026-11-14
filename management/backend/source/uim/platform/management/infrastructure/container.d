/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.container;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application, persistence and
/// infrastructure adapters. Presentation adapters (HTTP, REST, OData, CLI, GUI)
/// are created by the entry points (app.d, cli.d, gui.d) and only see ports().
class Container {
  ManagementConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  GlobalAccountRepository globalAccountRepo;
  DirectoryRepository directoryRepo;
  SubaccountRepository subaccountRepo;
  EntitlementRepository entitlementRepo;
  EnvironmentRepository environmentRepo;
  SubscriptionRepository subscriptionRepo;
  ServicePlanRepository servicePlanRepo;
  EnvironmentEventRepository eventRepo;
  LabelRepository labelRepo;
  IPlatformEventPublisher publisher;
  IProvisioningGateway provisioning;

  // ── Domain & application services ─────────────────────────────────────
  EntitlementEvaluator entitlementEvaluator;
  EnvironmentProvisioner environmentProvisioner;
  PlatformEventRecorder recorder;

  // ── Driving ports ─────────────────────────────────────────────────────
  IManageGlobalAccountsUseCase manageGlobalAccounts;
  IManageDirectoriesUseCase manageDirectories;
  IManageSubaccountsUseCase manageSubaccounts;
  IManageEntitlementsUseCase manageEntitlements;
  IManageEnvironmentsUseCase manageEnvironments;
  IManageSubscriptionsUseCase manageSubscriptions;
  IManageServicePlansUseCase manageServicePlans;
  IManageLabelsUseCase manageLabels;
  IQueryEnvironmentEventsUseCase queryEvents;
  IPruneEventsUseCase pruneEvents;
  IGetAccountOverviewUseCase getOverview;
  IDemoDataService demoData;

  this(ManagementConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  /// The driving ports for presentation adapters.
  ManagementPorts ports() {
    ManagementPorts p;
    p.globalAccounts = manageGlobalAccounts;
    p.directories = manageDirectories;
    p.subaccounts = manageSubaccounts;
    p.entitlements = manageEntitlements;
    p.environments = manageEnvironments;
    p.subscriptions = manageSubscriptions;
    p.servicePlans = manageServicePlans;
    p.labels = manageLabels;
    p.events = queryEvents;
    p.pruneEvents = pruneEvents;
    p.overview = getOverview;
    p.demoData = demoData;
    return p;
  }

  protected void wirePersistence() {
    if (config.usesFileStorage) {
      storage = new JsonFileSnapshotStorage(config.dataDir);
      globalAccountRepo = new GlobalAccountRepository(store!(GlobalAccount, GlobalAccountId, GlobalAccountMapper)(ManagementCollections.globalAccounts));
      directoryRepo = new DirectoryRepository(store!(AccountDirectory, DirectoryId, AccountDirectoryMapper)(ManagementCollections.directories));
      subaccountRepo = new SubaccountRepository(store!(Subaccount, SubaccountId, SubaccountMapper)(ManagementCollections.subaccounts));
      entitlementRepo = new EntitlementRepository(store!(Entitlement, EntitlementId, EntitlementMapper)(ManagementCollections.entitlements));
      environmentRepo = new EnvironmentRepository(store!(Environment, EnvironmentId, EnvironmentMapper)(ManagementCollections.environments));
      subscriptionRepo = new SubscriptionRepository(store!(Subscription, SubscriptionId, SubscriptionMapper)(ManagementCollections.subscriptions));
      servicePlanRepo = new ServicePlanRepository(store!(ServicePlan, ServicePlanId, ServicePlanMapper)(ManagementCollections.servicePlans));
      eventRepo = new EnvironmentEventRepository(store!(EnvironmentEvent, EnvironmentEventId, EnvironmentEventMapper)(ManagementCollections.events));
      labelRepo = new LabelRepository(store!(Label, LabelId, LabelMapper)(ManagementCollections.labels));
    } else {
      globalAccountRepo = new GlobalAccountRepository();
      directoryRepo = new DirectoryRepository();
      subaccountRepo = new SubaccountRepository();
      entitlementRepo = new EntitlementRepository();
      environmentRepo = new EnvironmentRepository();
      subscriptionRepo = new SubscriptionRepository();
      servicePlanRepo = new ServicePlanRepository();
      eventRepo = new EnvironmentEventRepository();
      labelRepo = new LabelRepository();
    }
    publisher = new LogEventPublisher();
    provisioning = new SimulatedProvisioningClient();
  }

  protected ITenantStore!(TEntity, TId) store(TEntity, TId, TMapper)(string collection) {
    return new SnapshotTenantStore!(TEntity, TId, TMapper)(storage, collection);
  }

  protected void wireApplication() {
    entitlementEvaluator = new EntitlementEvaluator();
    environmentProvisioner = new EnvironmentProvisioner();
    recorder = new PlatformEventRecorder(eventRepo, publisher);

    manageGlobalAccounts = new ManageGlobalAccountsUseCase(globalAccountRepo, subaccountRepo, directoryRepo, recorder);
    manageDirectories = new ManageDirectoriesUseCase(directoryRepo, globalAccountRepo, subaccountRepo, recorder);
    manageSubaccounts = new ManageSubaccountsUseCase(subaccountRepo, globalAccountRepo, directoryRepo,
      environmentRepo, subscriptionRepo, recorder);
    manageEntitlements = new ManageEntitlementsUseCase(entitlementRepo, servicePlanRepo, globalAccountRepo,
      subaccountRepo, directoryRepo, entitlementEvaluator, recorder);
    manageEnvironments = new ManageEnvironmentsUseCase(environmentRepo, subaccountRepo, environmentProvisioner,
      provisioning, recorder);
    manageSubscriptions = new ManageSubscriptionsUseCase(subscriptionRepo, subaccountRepo, servicePlanRepo,
      provisioning, recorder);
    manageServicePlans = new ManageServicePlansUseCase(servicePlanRepo, entitlementRepo);
    manageLabels = new ManageLabelsUseCase(labelRepo);
    auto events = new QueryEnvironmentEventsUseCase(eventRepo);
    queryEvents = events;
    pruneEvents = events;
    getOverview = new GetAccountOverviewUseCase(globalAccountRepo, subaccountRepo, directoryRepo, entitlementRepo,
      environmentRepo, subscriptionRepo, servicePlanRepo, labelRepo, eventRepo);
    demoData = new DemoDataService(manageGlobalAccounts, manageDirectories, manageSubaccounts, manageEntitlements,
      manageEnvironments, manageSubscriptions, manageServicePlans, manageLabels);
  }
}

/// Build the full dependency graph.
Container buildContainer(ManagementConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end through the ports"));

  ManagementConfig cfg;
  cfg.storage = "memory";
  auto ports = buildContainer(cfg).ports;
  auto t = TenantId("t1");

  // demo landscape goes through every use case
  auto seeded = ports.demoData.seed(t);
  assert(seeded.isSuccess, seeded.message);
  assert(!ports.demoData.isEmpty(t));
  assert(ports.demoData.seed(t).message.canFind("nothing seeded"));

  auto ov = ports.overview.getTenantOverview(t);
  assert(ov.globalAccounts == 1 && ov.subaccounts == 4 && ov.directories == 3);
  assert(ov.environments == 3 && ov.subscriptions == 2 && ov.entitlements == 7);
  assert(ov.events > 0, "events must be recorded with the tenant");

  auto ga = ports.globalAccounts.listAccounts(t)[0];
  assert(ga.currentSubaccounts == 4 && ga.currentDirectories == 3);

  // business rules
  auto sandbox = ports.subaccounts.listSubaccounts(t).filter!(s => s.subdomain == "acme-sandbox").front;
  assert(ports.subaccounts.suspendSubaccount(t, sandbox.id).isSuccess);
  auto again = ports.subaccounts.suspendSubaccount(t, sandbox.id);
  assert(!again.isSuccess && again.code == ResultCode.ruleViolation);
  assert(ports.subaccounts.reactivateSubaccount(t, sandbox.id).isSuccess);

  CreateSubaccountRequest dup;
  dup.tenantId = t;
  dup.globalAccountId = ga.id;
  dup.displayName = "Duplicate";
  dup.subdomain = "acme-sandbox";
  dup.region = "eu10";
  assert(ports.subaccounts.createSubaccount(dup).code == ResultCode.conflict);

  // a subaccount with environments cannot be deleted
  auto prod = ports.subaccounts.listSubaccounts(t).filter!(s => s.subdomain == "acme-sales-prod").front;
  assert(ports.subaccounts.deleteSubaccount(t, prod.id).code == ResultCode.ruleViolation);
  // ... a second CF environment is rejected
  CreateEnvironmentRequest cf;
  cf.tenantId = t;
  cf.subaccountId = prod.id;
  cf.name = "second";
  cf.environmentType = "cloudFoundry";
  cf.planName = "standard";
  assert(ports.environments.createEnvironment(cf).code == ResultCode.ruleViolation);

  // quota of hana-cloud (max 10) is checked across subaccounts
  auto hana = ports.servicePlans.listPlansByService(t, "hana-cloud")[0];
  AssignEntitlementRequest tooMuch;
  tooMuch.tenantId = t;
  tooMuch.subaccountId = sandbox.id;
  tooMuch.servicePlanId = hana.id;
  tooMuch.quotaAssigned = 6; // 2 + 3 already assigned
  assert(ports.entitlements.assignEntitlement(tooMuch).code == ResultCode.ruleViolation);
  tooMuch.quotaAssigned = 5;
  assert(ports.entitlements.assignEntitlement(tooMuch).isSuccess);

  // events can be queried and pruned
  QueryEventsRequest q;
  q.tenantId = t;
  q.category = "subaccountLifecycle";
  assert(ports.events.queryEvents(q).length >= 4);
  assert(ports.pruneEvents.pruneEvents(t, 30).data["removed"].get!long == 0);
}
