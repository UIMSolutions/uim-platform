/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.container;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageServiceInstancesUseCase   manageServiceInstancesUseCase;
    ManageServiceBindingsUseCase    manageServiceBindingsUseCase;
    ManageServicePlansUseCase       manageServicePlansUseCase;
    ManageConfigurationsUseCase     manageConfigurationsUseCase;
    ManageBackupPoliciesUseCase     manageBackupPoliciesUseCase;
    ManageDatabaseUsersUseCase      manageDatabaseUsersUseCase;
    ManageDatabaseExtensionsUseCase manageDatabaseExtensionsUseCase;
    ManageMaintenanceWindowsUseCase manageMaintenanceWindowsUseCase;

    ServiceInstanceController   serviceInstanceController;
    ServiceBindingController    serviceBindingController;
    ServicePlanController       servicePlanController;
    ConfigurationController     configurationController;
    BackupPolicyController      backupPolicyController;
    DatabaseUserController      databaseUserController;
    DatabaseExtensionController databaseExtensionController;
    MaintenanceWindowController maintenanceWindowController;
    HealthController            healthController;
}

Container buildContainer(SrvConfig config) @trusted {
    Container c;

    import vibe.db.mongo.mongo : connectMongoDB;

    ServiceInstanceRepository   instanceRepo;
    ServiceBindingRepository    bindingRepo;
    ServicePlanRepository       planRepo;
    ConfigurationRepository     configRepo;
    BackupPolicyRepository      backupRepo;
    DatabaseUserRepository      userRepo;
    DatabaseExtensionRepository extensionRepo;
    MaintenanceWindowRepository maintenanceRepo;

    final switch (config.persistence) {
        case "file":
            instanceRepo    = new FileServiceInstanceRepository(config.filePath);
            bindingRepo     = new FileServiceBindingRepository(config.filePath);
            planRepo        = new FileServicePlanRepository(config.filePath);
            configRepo      = new FileConfigurationRepository(config.filePath);
            backupRepo      = new FileBackupPolicyRepository(config.filePath);
            userRepo        = new FileDatabaseUserRepository(config.filePath);
            extensionRepo   = new FileDatabaseExtensionRepository(config.filePath);
            maintenanceRepo = new FileMaintenanceWindowRepository(config.filePath);
            break;
        case "mongodb":
            auto mongoDb = connectMongoDB(config.mongoUri)[config.mongoDb];
            instanceRepo    = new MongoServiceInstanceRepository(mongoDb["service_instances"]);
            bindingRepo     = new MongoServiceBindingRepository(mongoDb["service_bindings"]);
            planRepo        = new MongoServicePlanRepository(mongoDb["service_plans"]);
            configRepo      = new MongoConfigurationRepository(mongoDb["configurations"]);
            backupRepo      = new MongoBackupPolicyRepository(mongoDb["backup_policies"]);
            userRepo        = new MongoDatabaseUserRepository(mongoDb["database_users"]);
            extensionRepo   = new MongoDatabaseExtensionRepository(mongoDb["database_extensions"]);
            maintenanceRepo = new MongoMaintenanceWindowRepository(mongoDb["maintenance_windows"]);
            break;
        case "memory": goto default;
        default:
            instanceRepo    = new MemoryServiceInstanceRepository();
            bindingRepo     = new MemoryServiceBindingRepository();
            planRepo        = new MemoryServicePlanRepository();
            configRepo      = new MemoryConfigurationRepository();
            backupRepo      = new MemoryBackupPolicyRepository();
            userRepo        = new MemoryDatabaseUserRepository();
            extensionRepo   = new MemoryDatabaseExtensionRepository();
            maintenanceRepo = new MemoryMaintenanceWindowRepository();
            break;
    }

    // Use Cases
    c.manageServiceInstancesUseCase   = new ManageServiceInstancesUseCase(instanceRepo);
    c.manageServiceBindingsUseCase    = new ManageServiceBindingsUseCase(bindingRepo);
    c.manageServicePlansUseCase       = new ManageServicePlansUseCase(planRepo);
    c.manageConfigurationsUseCase     = new ManageConfigurationsUseCase(configRepo);
    c.manageBackupPoliciesUseCase     = new ManageBackupPoliciesUseCase(backupRepo);
    c.manageDatabaseUsersUseCase      = new ManageDatabaseUsersUseCase(userRepo);
    c.manageDatabaseExtensionsUseCase = new ManageDatabaseExtensionsUseCase(extensionRepo);
    c.manageMaintenanceWindowsUseCase = new ManageMaintenanceWindowsUseCase(maintenanceRepo);

    // Controllers
    c.serviceInstanceController   = new ServiceInstanceController(c.manageServiceInstancesUseCase);
    c.serviceBindingController    = new ServiceBindingController(c.manageServiceBindingsUseCase);
    c.servicePlanController       = new ServicePlanController(c.manageServicePlansUseCase);
    c.configurationController     = new ConfigurationController(c.manageConfigurationsUseCase);
    c.backupPolicyController      = new BackupPolicyController(c.manageBackupPoliciesUseCase);
    c.databaseUserController      = new DatabaseUserController(c.manageDatabaseUsersUseCase);
    c.databaseExtensionController = new DatabaseExtensionController(c.manageDatabaseExtensionsUseCase);
    c.maintenanceWindowController = new MaintenanceWindowController(c.manageMaintenanceWindowsUseCase);
    c.healthController            = new HealthController();

    return c;
}
