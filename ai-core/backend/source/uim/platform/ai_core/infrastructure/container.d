/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.ai_core.infrastructure.container;

import uim.platform.ai_core;
import uim.platform.ai_core.presentation.odata.engine : aiCoreEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class AiCoreContainer {
  AiCoreConfig config;
  IDocumentStore store;
  IClock clock;
  LoggingEventPublisher events;
  AiCoreRepositories repositories;
  AiCorePorts ports;
  ODataEngine engine; /// drives OData, CLI and GUI

  /// store / clock may be injected (tests); defaults follow the configuration.
  this(AiCoreConfig config, IDocumentStore store = null, IClock clock = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;

    // driven adapters
    repositories = createRepositories(this.store);

    // application
    auto policy = config.lifecycle;
    T wire(T, Args...)(Args extra) {
      auto uc = new T(repositories, this.clock, events, policy, extra);
      uc.defaultGroup = config.defaultResourceGroup;
      return uc;
    }

    auto executions = wire!ManageExecutionsUseCase();
    auto schedules = wire!ManageSchedulesUseCase(executions);
    ports.resourceGroups = wire!ManageResourceGroupsUseCase();
    ports.secrets = wire!ManageSecretsUseCase();
    ports.scenarios = wire!ManageScenariosUseCase();
    ports.executables = wire!ManageExecutablesUseCase();
    ports.configurations = wire!ManageConfigurationsUseCase();
    ports.artifacts = wire!ManageArtifactsUseCase();
    ports.executions = executions;
    ports.deployments = wire!ManageDeploymentsUseCase();
    ports.schedules = schedules;
    ports.metrics = wire!ManageMetricsUseCase();
    ports.reconciler = wire!ReconcileLifecycleUseCase(schedules);
    ports.statistics = new AiCoreStatisticsService(repositories, this.clock);

    // one engine for all management adapters
    engine = aiCoreEngine(ports, this.clock, config.maxPageSize);
  }
}
