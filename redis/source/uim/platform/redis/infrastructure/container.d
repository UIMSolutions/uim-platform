/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.container;

import uim.platform.redis;

mixin(ShowModule!());

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

Container buildContainer(SrvConfig config) @safe {
    Container c;

    // Repositories
    auto instanceRepo      = new MemoryServiceInstanceRepository();
    auto bindingRepo       = new MemoryServiceBindingRepository();
    auto planRepo          = new MemoryServicePlanRepository();
    auto configRepo        = new MemoryConfigurationRepository();
    auto cacheEntryRepo    = new MemoryCacheEntryRepository();
    auto metricRepo        = new MemoryMetricRepository();
    auto backupRepo        = new MemoryBackupPolicyRepository();
    auto accessControlRepo = new MemoryAccessControlRepository();

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
