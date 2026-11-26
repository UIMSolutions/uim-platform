/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.application_autoscaler.infrastructure.container;

import uim.platform.application_autoscaler;
import uim.platform.application_autoscaler.presentation.odata.engine : autoscalerEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class AasContainer {
  AasConfig config;
  IDocumentStore store;
  IAasUnitOfWork unitOfWork;
  IClock clock;
  LoggingEventPublisher events;
  AasRepositories repositories;
  AasPorts ports;
  IInstanceController instances;
  WorkerMetrics metrics;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / instance controller may be injected (tests); defaults follow the configuration.
  this(AasConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null, IInstanceController instances = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateAasUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;
    metrics = new WorkerMetrics;

    // driven adapters
    repositories = createRepositories(store);
    this.instances = instances !is null ? instances : config.instanceMode == "http"
      ? cast(IInstanceController) new HttpInstanceController(config.instanceUrl, config.instanceTimeoutSeconds)
      : cast(IInstanceController) new SimulatedInstanceController;

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, events, unitOfWork, p, extra);
    }

    ports.bindings = wire!ManageBindingsUseCase();
    ports.policies = wire!ManagePoliciesUseCase();
    ports.rules = wire!ManageRulesUseCase();
    ports.schedules = wire!ManageSchedulesUseCase();
    ports.metrics = wire!ManageMetricsUseCase();
    ports.scaling = wire!ScalingEngineUseCase(this.instances);
    ports.statistics = new AasStatisticsService(repositories, this.clock);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = autoscalerEngine(ports, this.clock, config.maxPageSize);
  }
}
