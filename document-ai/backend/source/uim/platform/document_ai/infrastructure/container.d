/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.document_ai.infrastructure.container;

import uim.platform.document_ai;
import uim.platform.document_ai.presentation.odata.engine : documentAiEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class DaiContainer {
  DaiConfig config;
  IDocumentStore store;
  IDaiUnitOfWork unitOfWork;
  IClock clock;
  LoggingEventPublisher events;
  DaiRepositories repositories;
  DaiPorts ports;
  IExtractionEngine extraction;
  ProcessingMetrics metrics;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / extraction engine may be injected (tests); defaults follow the configuration.
  this(DaiConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null, IExtractionEngine extraction = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateDaiUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;
    metrics = new ProcessingMetrics;

    // driven adapters
    repositories = createRepositories(store);
    this.extraction = extraction !is null ? extraction : config.extractionMode == "http"
      ? cast(IExtractionEngine) new HttpExtractionEngine(config.extractionUrl, config.extractionTimeoutSeconds)
      : cast(IExtractionEngine) new SimulatedExtractionEngine;

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, events, unitOfWork, p, extra);
    }

    ports.clients = wire!ManageClientsUseCase();
    ports.documentTypes = wire!ManageDocumentTypesUseCase();
    ports.schemas = wire!ManageSchemasUseCase();
    ports.schemaFields = wire!ManageSchemaFieldsUseCase();
    ports.templates = wire!ManageTemplatesUseCase();
    ports.enrichmentData = wire!ManageEnrichmentDataUseCase();
    ports.documents = wire!ProcessDocumentsUseCase(this.extraction);
    ports.fields = wire!ReviewFieldsUseCase();
    ports.trainingJobs = wire!ManageTrainingJobsUseCase();
    ports.statistics = new DaiStatisticsService(repositories, this.clock);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = documentAiEngine(ports, this.clock, config.policy, config.maxPageSize);
  }
}
