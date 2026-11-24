/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.data_retention.infrastructure.container;

import uim.platform.data_retention;
import uim.platform.data_retention.presentation.odata.engine : dataRetentionEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class DrContainer {
  DrConfig config;
  IDocumentStore store;
  IDrUnitOfWork unitOfWork;
  IClock clock;
  LoggingEventPublisher events;
  DrRepositories repositories;
  DrPorts ports;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock may be injected (tests); defaults follow the configuration.
  this(DrConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateDrUnitOfWork;
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

    ports.applicationGroups = wire!ManageApplicationGroupsUseCase();
    ports.legalEntities = wire!ManageLegalEntitiesUseCase();
    ports.dataSubjectRoles = wire!ManageDataSubjectRolesUseCase();
    ports.businessPurposes = wire!ManageBusinessPurposesUseCase();
    ports.legalGrounds = wire!ManageLegalGroundsUseCase();
    ports.residenceRules = wire!ManageResidenceRulesUseCase();
    ports.retentionRules = wire!ManageRetentionRulesUseCase();
    ports.dataSubjects = wire!ManageDataSubjectsUseCase();
    ports.checks = wire!RetentionChecksUseCase();
    ports.deletionRequests = wire!ManageDeletionRequestsUseCase();
    ports.archivingJobs = wire!ManageArchivingJobsUseCase();
    ports.statistics = new DrStatisticsService(repositories, this.clock);
    ports.lookups = new DrLookupsService(repositories);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = dataRetentionEngine(ports, this.clock, config.maxPageSize);
  }
}
