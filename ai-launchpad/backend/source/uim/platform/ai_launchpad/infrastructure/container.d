/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.ai_launchpad.infrastructure.container;

import uim.platform.ai_launchpad;
import uim.platform.ai_launchpad.presentation.odata.engine : launchpadEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class AilpContainer {
  AilpConfig config;
  IDocumentStore store;
  IAilpUnitOfWork unitOfWork;
  IClock clock;
  LoggingAuditTrail audit;
  AilpRepositories repositories;
  AilpPorts ports;
  IAiRuntime runtime;
  ReconcileMetrics metrics;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / runtime may be injected (tests); defaults follow the configuration.
  this(AilpConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null, IAiRuntime runtime = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateAilpUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    metrics = new ReconcileMetrics;

    // driven adapters
    repositories = createRepositories(store);
    audit = new LoggingAuditTrail(config.persistAuditLog ? repositories.logs : null, this.clock);
    this.runtime = runtime !is null ? runtime : new SimulatedAiRuntime(config.simulatedExecutionSeconds,
      config.simulatedDeploymentSeconds, config.simulatedFailurePercent);

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, audit, unitOfWork, p, extra);
    }

    ports.workspaces = wire!ManageWorkspacesUseCase();
    ports.connections = wire!ManageConnectionsUseCase(this.runtime);
    ports.resourceGroups = wire!ManageResourceGroupsUseCase();
    ports.scenarios = wire!ManageScenariosUseCase();
    ports.configurations = wire!ManageConfigurationsUseCase();
    ports.executions = wire!ManageExecutionsUseCase();
    ports.deployments = wire!ManageDeploymentsUseCase();
    ports.reconciler = wire!ReconcileRuntimeUseCase(this.runtime);
    ports.models = wire!ManageModelsUseCase();
    ports.datasets = wire!ManageDatasetsUseCase();
    ports.promptCollections = wire!ManagePromptCollectionsUseCase();
    ports.prompts = wire!ManagePromptsUseCase(this.runtime);
    ports.statistics = new AilpStatisticsService(repositories, this.clock);
    ports.tiles = wire!ManageTilesUseCase(ports.statistics);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;
    ports.roles = wire!ManageRolesUseCase();
    ports.auditLog = wire!AuditLogUseCase();

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = launchpadEngine(ports, this.clock, config.maxPageSize);
  }

  /// Built-in roles and the default tiles of a tenant (idempotent).
  void bootstrapTenant(string tenant) {
    auto t = TenantId(tenant);
    unitOfWork.batch(() {
      ports.roles.ensureBuiltInRoles(t);
      ports.tiles.ensureDefaults(t);
    });
  }
}
