/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.architecture.infrastructure.container;

import uim.platform.architecture;
import uim.platform.architecture.presentation.odata.engine : architectureEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class ArchitectureContainer {
  ArchitectureConfig config;
  IDocumentStore store;
  IClock clock;
  LoggingEventPublisher events;
  ArchitectureRepositories repositories;
  ArchitecturePorts ports;
  ODataEngine engine; /// drives OData, CLI and GUI

  /// store / clock may be injected (tests); defaults follow the configuration.
  this(ArchitectureConfig config, IDocumentStore store = null, IClock clock = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;

    // driven adapters
    repositories = createRepositories(this.store);

    // application
    ports.blocks = new ManageBuildingBlocksUseCase(repositories, this.clock, events);
    ports.relationships = new ManageRelationshipsUseCase(repositories, this.clock, events);
    ports.analysis = new AnalyzeArchitectureUseCase(repositories, this.clock);
    ports.exporter = new ExportArchiMateUseCase(repositories, this.clock);
    ports.seeder = new DemoDataSeeder(ports.blocks, ports.relationships);

    // one engine for all management adapters
    engine = architectureEngine(ports, config.maxPageSize);
  }

  /// Seed the default tenant if configured and empty. Returns true if seeded.
  bool seedIfConfigured() {
    if (!config.seedDemoData)
      return false;
    auto t = TenantId(config.defaultTenant);
    if (repositories.blocks.countAll(t) > 0)
      return false;
    ports.seeder.seed(t, UserId("system"));
    return true;
  }
}
