/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.container;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

struct Container {
    // Use cases
    ManageFeatureFlagsUseCase    manageFlagsUseCase;
    EvaluateFlagsUseCase         evaluateFlagsUseCase;
    ManageServiceInstancesUseCase manageInstancesUseCase;

    // HTTP Controllers
    FeatureFlagController    featureFlagController;
    EvaluationController     evaluationController;
    ServiceInstanceController serviceInstanceController;

    // Web Views (MVC)
    FeatureFlagWebView featureFlagWebView;

    // CLI Commands (MVC)
    FeatureFlagCliCommand flagCliCommand;
    EvaluationCliCommand  evalCliCommand;

    // GUI Widgets (MVC)
    FeatureFlagWidget flagWidget;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // ----------------------------------------------------------------
    // Select repositories based on configured storage backend
    // ----------------------------------------------------------------
    FeatureFlagRepository    flagRepo;
    ServiceInstanceRepository instRepo;
    AuditEntryRepository     auditRepo;

    switch (config.storageBackend) {
        case "FILE":
            flagRepo  = new FileFeatureFlagRepository(config.fileStoragePath);
            instRepo  = new FileServiceInstanceRepository(config.fileStoragePath);
            auditRepo = new FileAuditEntryRepository(config.fileStoragePath);
            break;

        case "MONGODB":
            flagRepo  = new MongoDbFeatureFlagRepository(config.mongoUri, config.mongoDb);
            instRepo  = new MongoDbServiceInstanceRepository(config.mongoUri, config.mongoDb);
            auditRepo = new MongoDbAuditEntryRepository(config.mongoUri, config.mongoDb);
            break;

        default: // "MEMORY"
            flagRepo  = new MemoryFeatureFlagRepository();
            instRepo  = new MemoryServiceInstanceRepository();
            auditRepo = new MemoryAuditEntryRepository();
            break;
    }

    // ----------------------------------------------------------------
    // Use Cases
    // ----------------------------------------------------------------
    c.manageFlagsUseCase     = new ManageFeatureFlagsUseCase(flagRepo, auditRepo);
    c.evaluateFlagsUseCase   = new EvaluateFlagsUseCase(flagRepo);
    c.manageInstancesUseCase = new ManageServiceInstancesUseCase(instRepo, auditRepo);

    // ----------------------------------------------------------------
    // HTTP Controllers
    // ----------------------------------------------------------------
    c.featureFlagController    = new FeatureFlagController(c.manageFlagsUseCase);
    c.evaluationController     = new EvaluationController(c.evaluateFlagsUseCase);
    c.serviceInstanceController = new ServiceInstanceController(c.manageInstancesUseCase);

    // ----------------------------------------------------------------
    // Web Views
    // ----------------------------------------------------------------
    c.featureFlagWebView = new FeatureFlagWebView(c.manageFlagsUseCase);

    // ----------------------------------------------------------------
    // CLI Commands
    // ----------------------------------------------------------------
    c.flagCliCommand = new FeatureFlagCliCommand(c.manageFlagsUseCase);
    c.evalCliCommand = new EvaluationCliCommand(c.evaluateFlagsUseCase);

    // ----------------------------------------------------------------
    // GUI Widgets
    // ----------------------------------------------------------------
    c.flagWidget = new FeatureFlagWidget(c.manageFlagsUseCase);

    return c;
}
