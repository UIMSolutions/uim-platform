/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.container;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageServiceInstancesUseCase manageServiceInstancesUseCase;
    ManageServiceBindingsUseCase  manageServiceBindingsUseCase;
    ManageServicePlansUseCase     manageServicePlansUseCase;
    ManageConfigurationsUseCase   manageConfigurationsUseCase;
    ManageCacheEntriesUseCase     manageCacheEntriesUseCase;
    ManageMetricsUseCase          manageMetricsUseCase;
    ManageBackupPoliciesUseCase   manageBackupPoliciesUseCase;
    ManageAccessControlsUseCase   manageAccessControlsUseCase;

    ServiceInstanceController serviceInstanceController;
    ServiceBindingController  serviceBindingController;
    ServicePlanController     servicePlanController;
    ConfigurationController   configurationController;
    CacheEntryController      cacheEntryController;
    MetricController          metricController;
    BackupPolicyController    backupPolicyController;
    AccessControlController   accessControlController;
    HealthController          healthController;
}

Container buildContainer(SrvConfig config) @trusted {
    Container c;

    import vibe.db.mongo.mongo : connectMongoDB;

    // Repositories
    ServiceInstanceRepository  instanceRepo;
    ServiceBindingRepository   bindingRepo;
    ServicePlanRepository      planRepo;
    ConfigurationRepository    configRepo;
    CacheEntryRepository       cacheEntryRepo;
    MetricRepository           metricRepo;
    BackupPolicyRepository     backupRepo;
    AccessControlRepository    accessControlRepo;

    final switch (config.persistence) {
        case "file":
            instanceRepo      = new FileServiceInstanceRepository(config.filePath);
            bindingRepo       = new FileServiceBindingRepository(config.filePath);
            planRepo          = new FileServicePlanRepository(config.filePath);
            configRepo        = new FileConfigurationRepository(config.filePath);
            cacheEntryRepo    = new FileCacheEntryRepository(config.filePath);
            metricRepo        = new FileMetricRepository(config.filePath);
            backupRepo        = new FileBackupPolicyRepository(config.filePath);
            accessControlRepo = new FileAccessControlRepository(config.filePath);
            break;
        case "mongodb":
            auto mongoDb = connectMongoDB(config.mongoUri)[config.mongoDb];
            instanceRepo      = new MongoServiceInstanceRepository(mongoDb["service_instances"]);
            bindingRepo       = new MongoServiceBindingRepository(mongoDb["service_bindings"]);
            planRepo          = new MongoServicePlanRepository(mongoDb["service_plans"]);
            configRepo        = new MongoConfigurationRepository(mongoDb["configurations"]);
            cacheEntryRepo    = new MongoCacheEntryRepository(mongoDb["cache_entries"]);
            metricRepo        = new MongoMetricRepository(mongoDb["metrics"]);
            backupRepo        = new MongoBackupPolicyRepository(mongoDb["backup_policies"]);
            accessControlRepo = new MongoAccessControlRepository(mongoDb["access_controls"]);
            break;
        case "memory": goto default;
        default:
            instanceRepo      = new MemoryServiceInstanceRepository();
            bindingRepo       = new MemoryServiceBindingRepository();
            planRepo          = new MemoryServicePlanRepository();
            configRepo        = new MemoryConfigurationRepository();
            cacheEntryRepo    = new MemoryCacheEntryRepository();
            metricRepo        = new MemoryMetricRepository();
            backupRepo        = new MemoryBackupPolicyRepository();
            accessControlRepo = new MemoryAccessControlRepository();
            break;
    }

    // Use Cases
    c.manageServiceInstancesUseCase = new ManageServiceInstancesUseCase(instanceRepo);
    c.manageServiceBindingsUseCase  = new ManageServiceBindingsUseCase(bindingRepo);
    c.manageServicePlansUseCase     = new ManageServicePlansUseCase(planRepo);
    c.manageConfigurationsUseCase   = new ManageConfigurationsUseCase(configRepo);
    c.manageCacheEntriesUseCase     = new ManageCacheEntriesUseCase(cacheEntryRepo);
    c.manageMetricsUseCase          = new ManageMetricsUseCase(metricRepo);
    c.manageBackupPoliciesUseCase   = new ManageBackupPoliciesUseCase(backupRepo);
    c.manageAccessControlsUseCase   = new ManageAccessControlsUseCase(accessControlRepo);

    // Controllers
    c.serviceInstanceController = new ServiceInstanceController(c.manageServiceInstancesUseCase);
    c.serviceBindingController  = new ServiceBindingController(c.manageServiceBindingsUseCase);
    c.servicePlanController     = new ServicePlanController(c.manageServicePlansUseCase);
    c.configurationController   = new ConfigurationController(c.manageConfigurationsUseCase);
    c.cacheEntryController      = new CacheEntryController(c.manageCacheEntriesUseCase);
    c.metricController          = new MetricController(c.manageMetricsUseCase);
    c.backupPolicyController    = new BackupPolicyController(c.manageBackupPoliciesUseCase);
    c.accessControlController   = new AccessControlController(c.manageAccessControlsUseCase);
    c.healthController          = new HealthController();

    return c;
}
