module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.master_data_object_repo;
import infrastructure.persistence.memory.data_model_repo;
import infrastructure.persistence.memory.distribution_model_repo;
import infrastructure.persistence.memory.key_mapping_repo;
import infrastructure.persistence.memory.change_log_repo;
import infrastructure.persistence.memory.client_repo;
import infrastructure.persistence.memory.replication_job_repo;
import infrastructure.persistence.memory.filter_rule_repo;

// Domain services
import domain.services.key_mapping_resolver;
import domain.services.distribution_evaluator;

// Use Cases
import application.use_cases.manage_master_data_objects;
import application.use_cases.manage_data_models;
import application.use_cases.manage_distribution_models;
import application.use_cases.manage_key_mappings;
import application.use_cases.manage_clients;
import application.use_cases.manage_replication_jobs;
import application.use_cases.manage_filter_rules;
import application.use_cases.query_change_log;

// Controllers
import presentation.http.master_data_controller;
import presentation.http.data_model_controller;
import presentation.http.distribution_controller;
import presentation.http.key_mapping_controller;
import presentation.http.client_controller;
import presentation.http.replication_controller;
import presentation.http.filter_rule_controller;
import presentation.http.change_log_controller;
import presentation.http.health_controller;

/// Dependency injection container — wires all layers together.
struct Container
{
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
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.mdoRepo = new InMemoryMasterDataObjectRepository();
    c.dataModelRepo = new InMemoryDataModelRepository();
    c.distRepo = new InMemoryDistributionModelRepository();
    c.keyMapRepo = new InMemoryKeyMappingRepository();
    c.changeLogRepo = new InMemoryChangeLogRepository();
    c.clientRepo = new InMemoryClientRepository();
    c.replJobRepo = new InMemoryReplicationJobRepository();
    c.filterRuleRepo = new InMemoryFilterRuleRepository();

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
    c.healthController = new HealthController();

    return c;
}
