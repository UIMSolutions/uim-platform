/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.data_quality.infrastructure.container;

import uim.platform.data_quality;
import uim.platform.data_quality.presentation.odata.engine : dataQualityEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class DqContainer {
  DqConfig config;
  IDocumentStore store;
  IDqUnitOfWork unitOfWork;
  IClock clock;
  LoggingEventPublisher events;
  DqRepositories repositories;
  DqPorts ports;
  ODataEngine engine; /// drives OData, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock may be injected (tests); defaults follow the configuration.
  this(DqConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateDqUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    events = new LoggingEventPublisher;

    // driven adapters
    repositories = createRepositories(store);

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, events, unitOfWork, p, extra);
    }

    auto validationRules = wire!ManageValidationRulesUseCase();
    auto cleansingRules = wire!ManageCleansingRulesUseCase();
    auto scorecards = wire!ManageScorecardsUseCase();
    auto validation = wire!ValidateDataUseCase(cast(IManageValidationRules) validationRules, scorecards);

    ports.datasets = wire!ManageDatasetsUseCase();
    ports.records = wire!ManageRecordsUseCase(validation, scorecards);
    ports.validationRules = validationRules;
    ports.cleansingRules = cleansingRules;
    ports.validation = validation;
    ports.profiling = wire!ProfileDataUseCase(scorecards);
    ports.duplicates = wire!DetectDuplicatesUseCase(validation, scorecards);
    ports.scorecards = scorecards;
    ports.cleansingJobs = wire!ManageCleansingJobsUseCase(cast(IManageCleansingRules) cleansingRules, validation);
    ports.addresses = wire!CleanseAddressesUseCase();
    ports.statistics = new DqStatisticsService(repositories, this.clock);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters
    engine = dataQualityEngine(ports, config.maxPageSize);
  }
}
