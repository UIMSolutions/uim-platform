/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.integration_automation.infrastructure.container;

import uim.platform.integration_automation;
import uim.platform.integration_automation.presentation.odata.engine : integrationAutomationEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class IaContainer {
  IaConfig config;
  IDocumentStore store;
  IIaUnitOfWork unitOfWork;
  IClock clock;
  LoggingEventPublisher events;
  IaRepositories repositories;
  IaPorts ports;
  IAutomationGateway automation;
  IConnectivityProbe connectivity;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / gateways may be injected (tests); defaults follow the configuration.
  this(IaConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null,
    IAutomationGateway automation = null, IConnectivityProbe connectivity = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateIaUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;

    // driven adapters
    repositories = createRepositories(store);
    this.automation = automation !is null ? automation : config.automationMode == "http"
      ? cast(IAutomationGateway) new HttpAutomationGateway(config.automationTimeoutSeconds, config.notificationWebhookUrl)
      : cast(IAutomationGateway) new SimulatedAutomationGateway;
    this.connectivity = connectivity !is null ? connectivity : config.connectivityMode == "tcp"
      ? cast(IConnectivityProbe) new TcpConnectivityProbe(config.connectivityTimeoutSeconds)
      : cast(IConnectivityProbe) new SimulatedConnectivityProbe;

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, events, unitOfWork, p, extra);
    }

    ports.systems = wire!ManageSystemsUseCase(this.connectivity);
    ports.destinations = wire!ManageDestinationsUseCase();
    ports.scenarios = wire!ManageScenariosUseCase();
    ports.scenarioTasks = wire!ManageScenarioTasksUseCase();
    auto tasks = wire!ProcessTasksUseCase(this.automation);
    ports.tasks = tasks;
    ports.workflows = wire!ManageWorkflowsUseCase(cast(IProcessTasks) tasks);
    ports.executions = wire!MonitorExecutionsUseCase();
    ports.statistics = new IaStatisticsService(repositories, this.clock, p);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = integrationAutomationEngine(ports, this.clock, config.maxPageSize);
  }
}
