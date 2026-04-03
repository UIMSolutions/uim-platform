/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.master_data_object_repo;
import uim.platform.xyz.infrastructure.persistence.memory.data_model_repo;
import uim.platform.xyz.infrastructure.persistence.memory.distribution_model_repo;
import uim.platform.xyz.infrastructure.persistence.memory.key_mapping_repo;
import uim.platform.xyz.infrastructure.persistence.memory.change_log_repo;
import uim.platform.xyz.infrastructure.persistence.memory.client_repo;
import uim.platform.xyz.infrastructure.persistence.memory.replication_job_repo;
import uim.platform.xyz.infrastructure.persistence.memory.filter_rule_repo;

// Domain services
import domain.services.key_mapping_resolver;
import domain.services.distribution_evaluator;

// Use Cases
import application.usecases.manage_master_data_objects;
import application.usecases.manage_data_models;
import application.usecases.manage_distribution_models;
import application.usecases.manage_key_mappings;
import application.usecases.manage_clients;
import application.usecases.manage_replication_jobs;
import application.usecases.manage_filter_rules;
import application.usecases.query_change_log;

// Controllers
import presentation.http.master_data;
import presentation.http.data_model;
import presentation.http.distribution;
import presentation.http.key_mapping;
import presentation.http.client;
import presentation.http.replication;
import presentation.http.filter_rule;
import presentation.http.change_log;
import presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container {
    // Repositories (driven adapters)
    InMemoryMasterDataObjectRepository mdoRepo;
    InMemoryDataModelRepository dataModelRepo;
    InMemoryDistributionModelRepository distRepo;
    InMemoryKeyMappingRepository keyMapRepo;
    InMemoryChangeLogRepository changeLogRepo;
    InMemoryClientRepository clientRepo;
    InMemoryReplicationJobRepository replJobRepo;
    InMemoryFilterRuleRepository filterRuleRepo;

    // Domain services
    KeyMappingResolver keyMapResolver;
    DistributionEvaluator distEvaluator;

    // Use cases (application layer)
    ManageMasterDataObjectsUseCase manageMasterData;
    ManageDataModelsUseCase manageDataModels;
    ManageDistributionModelsUseCase manageDistribution;
    ManageKeyMappingsUseCase manageKeyMappings;
    ManageClientsUseCase manageClients;
    ManageReplicationJobsUseCase manageReplicationJobs;
    ManageFilterRulesUseCase manageFilterRules;
    QueryChangeLogUseCase queryChangeLog;

    // Controllers (driving adapters)
    MasterDataController masterDataController;
    DataModelController dataModelController;
    DistributionController distributionController;
    KeyMappingController keyMappingController;
    ClientController clientController;
    ReplicationController replicationController;
    FilterRuleController filterRuleController;
    ChangeLogController changeLogController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.mdoRepo = new MemoryMasterDataObjectRepository();
    c.dataModelRepo = new MemoryDataModelRepository();
    c.distRepo = new MemoryDistributionModelRepository();
    c.keyMapRepo = new MemoryKeyMappingRepository();
    c.changeLogRepo = new MemoryChangeLogRepository();
    c.clientRepo = new MemoryClientRepository();
    c.replJobRepo = new MemoryReplicationJobRepository();
    c.filterRuleRepo = new MemoryFilterRuleRepository();

    // Domain services
    c.keyMapResolver = new KeyMappingResolver();
    c.distEvaluator = new DistributionEvaluator();

    // Application use cases
    c.manageMasterData = new ManageMasterDataObjectsUseCase(c.mdoRepo, c.changeLogRepo);
    c.manageDataModels = new ManageDataModelsUseCase(c.dataModelRepo);
    c.manageDistribution = new ManageDistributionModelsUseCase(c.distRepo);
    c.manageKeyMappings = new ManageKeyMappingsUseCase(c.keyMapRepo, c.keyMapResolver);
    c.manageClients = new ManageClientsUseCase(c.clientRepo);
    c.manageReplicationJobs = new ManageReplicationJobsUseCase(c.replJobRepo);
    c.manageFilterRules = new ManageFilterRulesUseCase(c.filterRuleRepo);
    c.queryChangeLog = new QueryChangeLogUseCase(c.changeLogRepo);

    // Presentation controllers
    c.masterDataController = new MasterDataController(c.manageMasterData);
    c.dataModelController = new DataModelController(c.manageDataModels);
    c.distributionController = new DistributionController(c.manageDistribution);
    c.keyMappingController = new KeyMappingController(c.manageKeyMappings);
    c.clientController = new ClientController(c.manageClients);
    c.replicationController = new ReplicationController(c.manageReplicationJobs);
    c.filterRuleController = new FilterRuleController(c.manageFilterRules);
    c.changeLogController = new ChangeLogController(c.queryChangeLog);
    c.healthController = new HealthController("master-data-integration");

    return c;
}
