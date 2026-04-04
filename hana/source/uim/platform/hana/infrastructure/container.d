/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.container;

import uim.platform.hana.infrastructure.config;

// Repositories
import uim.platform.hana.infrastructure.persistence.memory.instance_repo;
import uim.platform.hana.infrastructure.persistence.memory.data_lake_repo;
import uim.platform.hana.infrastructure.persistence.memory.schema_repo;
import uim.platform.hana.infrastructure.persistence.memory.database_user_repo;
import uim.platform.hana.infrastructure.persistence.memory.backup_repo;
import uim.platform.hana.infrastructure.persistence.memory.alert_repo;
import uim.platform.hana.infrastructure.persistence.memory.hdi_container_repo;
import uim.platform.hana.infrastructure.persistence.memory.replication_task_repo;
import uim.platform.hana.infrastructure.persistence.memory.configuration_repo;
import uim.platform.hana.infrastructure.persistence.memory.database_connection_repo;

// Use Cases
import uim.platform.hana.application.usecases.manage.instances;
import uim.platform.hana.application.usecases.manage.data_lakes;
import uim.platform.hana.application.usecases.manage.schemas;
import uim.platform.hana.application.usecases.manage.database_users;
import uim.platform.hana.application.usecases.manage.backups;
import uim.platform.hana.application.usecases.manage.alerts;
import uim.platform.hana.application.usecases.manage.hdi_containers;
import uim.platform.hana.application.usecases.manage.replication_tasks;
import uim.platform.hana.application.usecases.manage.configurations;
import uim.platform.hana.application.usecases.manage.database_connections;

// Controllers
import uim.platform.hana.presentation.http.controllers.instance;
import uim.platform.hana.presentation.http.controllers.data_lake;
import uim.platform.hana.presentation.http.controllers.schema;
import uim.platform.hana.presentation.http.controllers.database_user;
import uim.platform.hana.presentation.http.controllers.backup;
import uim.platform.hana.presentation.http.controllers.alert;
import uim.platform.hana.presentation.http.controllers.hdi_container;
import uim.platform.hana.presentation.http.controllers.replication_task;
import uim.platform.hana.presentation.http.controllers.configuration;
import uim.platform.hana.presentation.http.controllers.database_connection;
import uim.platform.hana.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryInstanceRepository instanceRepo;
  MemoryDataLakeRepository dataLakeRepo;
  MemorySchemaRepository schemaRepo;
  MemoryDatabaseUserRepository databaseUserRepo;
  MemoryBackupRepository backupRepo;
  MemoryAlertRepository alertRepo;
  MemoryHDIContainerRepository hdiContainerRepo;
  MemoryReplicationTaskRepository replicationTaskRepo;
  MemoryConfigurationRepository configurationRepo;
  MemoryDatabaseConnectionRepository databaseConnectionRepo;

  // Use cases (application layer)
  ManageInstancesUseCase manageInstances;
  ManageDataLakesUseCase manageDataLakes;
  ManageSchemasUseCase manageSchemas;
  ManageDatabaseUsersUseCase manageDatabaseUsers;
  ManageBackupsUseCase manageBackups;
  ManageAlertsUseCase manageAlerts;
  ManageHDIContainersUseCase manageHDIContainers;
  ManageReplicationTasksUseCase manageReplicationTasks;
  ManageConfigurationsUseCase manageConfigurations;
  ManageDatabaseConnectionsUseCase manageDatabaseConnections;

  // Controllers (driving adapters)
  InstanceController instanceController;
  DataLakeController dataLakeController;
  SchemaController schemaController;
  DatabaseUserController databaseUserController;
  BackupController backupController;
  AlertController alertController;
  HDIContainerController hdiContainerController;
  ReplicationTaskController replicationTaskController;
  ConfigurationController configurationController;
  DatabaseConnectionController databaseConnectionController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.instanceRepo = new MemoryInstanceRepository();
  c.dataLakeRepo = new MemoryDataLakeRepository();
  c.schemaRepo = new MemorySchemaRepository();
  c.databaseUserRepo = new MemoryDatabaseUserRepository();
  c.backupRepo = new MemoryBackupRepository();
  c.alertRepo = new MemoryAlertRepository();
  c.hdiContainerRepo = new MemoryHDIContainerRepository();
  c.replicationTaskRepo = new MemoryReplicationTaskRepository();
  c.configurationRepo = new MemoryConfigurationRepository();
  c.databaseConnectionRepo = new MemoryDatabaseConnectionRepository();

  // Application use cases
  c.manageInstances = new ManageInstancesUseCase(c.instanceRepo);
  c.manageDataLakes = new ManageDataLakesUseCase(c.dataLakeRepo);
  c.manageSchemas = new ManageSchemasUseCase(c.schemaRepo);
  c.manageDatabaseUsers = new ManageDatabaseUsersUseCase(c.databaseUserRepo);
  c.manageBackups = new ManageBackupsUseCase(c.backupRepo);
  c.manageAlerts = new ManageAlertsUseCase(c.alertRepo);
  c.manageHDIContainers = new ManageHDIContainersUseCase(c.hdiContainerRepo);
  c.manageReplicationTasks = new ManageReplicationTasksUseCase(c.replicationTaskRepo);
  c.manageConfigurations = new ManageConfigurationsUseCase(c.configurationRepo);
  c.manageDatabaseConnections = new ManageDatabaseConnectionsUseCase(c.databaseConnectionRepo);

  // Presentation controllers
  c.instanceController = new InstanceController(c.manageInstances);
  c.dataLakeController = new DataLakeController(c.manageDataLakes);
  c.schemaController = new SchemaController(c.manageSchemas);
  c.databaseUserController = new DatabaseUserController(c.manageDatabaseUsers);
  c.backupController = new BackupController(c.manageBackups);
  c.alertController = new AlertController(c.manageAlerts);
  c.hdiContainerController = new HDIContainerController(c.manageHDIContainers);
  c.replicationTaskController = new ReplicationTaskController(c.manageReplicationTasks);
  c.configurationController = new ConfigurationController(c.manageConfigurations);
  c.databaseConnectionController = new DatabaseConnectionController(c.manageDatabaseConnections);
  c.healthController = new HealthController();

  return c;
}
