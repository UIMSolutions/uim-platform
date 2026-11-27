/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.datasphere.infrastructure.container;

import uim.platform.datasphere;
import uim.platform.datasphere.presentation.odata.engine : datasphereEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class DspContainer {
  DspConfig config;
  IDocumentStore store;
  IDspUnitOfWork unitOfWork;
  IClock clock;
  LoggingAuditTrail audit;
  DspRepositories repositories;
  DspPorts ports;
  IProcessingEngine processing;
  RunService runner;
  SchedulerMetrics metrics;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / processing engine may be injected (tests); defaults follow the configuration.
  this(DspConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null, IProcessingEngine processing = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateDspUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    audit = new LoggingAuditTrail;
    metrics = new SchedulerMetrics;

    // driven adapters
    repositories = createRepositories(store);
    this.processing = processing !is null ? processing : new SimulatedProcessingEngine(config.simulatedFailurePercent);

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, audit, unitOfWork, p, extra);
    }

    runner = wire!RunService(this.processing);
    ports.spaces = wire!ManageSpacesUseCase(runner);
    ports.members = wire!ManageMembersUseCase();
    ports.connections = wire!ManageConnectionsUseCase(runner);
    ports.remoteTables = wire!ManageRemoteTablesUseCase(runner);
    ports.views = wire!ManageViewsUseCase(runner);
    ports.dataFlows = wire!ManageDataFlowsUseCase(runner);
    ports.tasks = wire!ManageTasksUseCase(runner);
    ports.taskChains = wire!ManageTaskChainsUseCase(runner);
    ports.monitor = wire!MonitorRunsUseCase(runner);
    ports.accessControls = wire!ManageAccessControlsUseCase();
    ports.catalog = wire!ManageCatalogUseCase();
    ports.statistics = new DspStatisticsService(repositories, this.clock);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = datasphereEngine(ports, this.clock, config.maxPageSize);
  }
}
