/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.container;

import uim.platform.ai_launchpad.infrastructure.config;

// Domain services
import uim.platform.ai_launchpad.domain.services.connection_validator;
import uim.platform.ai_launchpad.domain.services.prompt_enricher;

// Repositories
import uim.platform.ai_launchpad.infrastructure.persistence.memory.connections;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.workspaces;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.scenarios;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.configurations;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.executions;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.deployments;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.models;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.datasets;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.prompts;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.prompt_collections;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.resource_groups;
import uim.platform.ai_launchpad.infrastructure.persistence.memory.usage_statistics;

// Use Cases
import uim.platform.ai_launchpad.application.usecases.manage.connections;
import uim.platform.ai_launchpad.application.usecases.manage.workspaces;
import uim.platform.ai_launchpad.application.usecases.manage.scenarios;
import uim.platform.ai_launchpad.application.usecases.manage.configurations;
import uim.platform.ai_launchpad.application.usecases.manage.executions;
import uim.platform.ai_launchpad.application.usecases.manage.deployments;
import uim.platform.ai_launchpad.application.usecases.manage.models;
import uim.platform.ai_launchpad.application.usecases.manage.datasets;
import uim.platform.ai_launchpad.application.usecases.manage.prompts;
import uim.platform.ai_launchpad.application.usecases.manage.prompt_collections;
import uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
import uim.platform.ai_launchpad.application.usecases.get_usage_statistics;
import uim.platform.ai_launchpad.application.usecases.get_capabilities;

// Controllers
import uim.platform.ai_launchpad.presentation.http.controllers.connection;
import uim.platform.ai_launchpad.presentation.http.controllers.workspace;
import uim.platform.ai_launchpad.presentation.http.controllers.scenario;
import uim.platform.ai_launchpad.presentation.http.controllers.configuration;
import uim.platform.ai_launchpad.presentation.http.controllers.execution;
import uim.platform.ai_launchpad.presentation.http.controllers.deployment;
import uim.platform.ai_launchpad.presentation.http.controllers.model;
import uim.platform.ai_launchpad.presentation.http.controllers.dataset;
import uim.platform.ai_launchpad.presentation.http.controllers.prompt;
import uim.platform.ai_launchpad.presentation.http.controllers.prompt_collection;
import uim.platform.ai_launchpad.presentation.http.controllers.resource_group;
import uim.platform.ai_launchpad.presentation.http.controllers.statistics;
import uim.platform.ai_launchpad.presentation.http.controllers.capabilities;
import uim.platform.ai_launchpad.presentation.http.controllers.health;

struct Container {
  // Domain services
  ConnectionValidator connectionValidator;
  PromptEnricher promptEnricher;

  // Repositories (driven adapters)
  MemoryConnectionRepository connectionRepo;
  MemoryWorkspaceRepository workspaceRepo;
  MemoryScenarioRepository scenarioRepo;
  MemoryConfigurationRepository configurationRepo;
  MemoryExecutionRepository executionRepo;
  MemoryDeploymentRepository deploymentRepo;
  MemoryModelRepository modelRepo;
  MemoryDatasetRepository datasetRepo;
  MemoryPromptRepository promptRepo;
  MemoryPromptCollectionRepository promptCollectionRepo;
  MemoryResourceGroupRepository resourceGroupRepo;
  MemoryUsageStatisticRepository usageStatisticRepo;

  // Use cases (application layer)
  ManageConnectionsUseCase manageConnections;
  ManageWorkspacesUseCase manageWorkspaces;
  ManageScenariosUseCase manageScenarios;
  ManageConfigurationsUseCase manageConfigurations;
  ManageExecutionsUseCase manageExecutions;
  ManageDeploymentsUseCase manageDeployments;
  ManageModelsUseCase manageModels;
  ManageDatasetsUseCase manageDatasets;
  ManagePromptsUseCase managePrompts;
  ManagePromptCollectionsUseCase managePromptCollections;
  ManageResourceGroupsUseCase manageResourceGroups;
  GetUsageStatisticsUseCase getUsageStatistics;
  GetCapabilitiesUseCase getCapabilities;

  // Controllers (driving adapters)
  ConnectionController connectionController;
  WorkspaceController workspaceController;
  ScenarioController scenarioController;
  ConfigurationController configurationController;
  ExecutionController executionController;
  DeploymentController deploymentController;
  ModelController modelController;
  DatasetController datasetController;
  PromptController promptController;
  PromptCollectionController promptCollectionController;
  ResourceGroupController resourceGroupController;
  StatisticsController statisticsController;
  CapabilitiesController capabilitiesController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Domain services
  c.connectionValidator = new ConnectionValidator();
  c.promptEnricher = new PromptEnricher();

  // Infrastructure adapters
  c.connectionRepo = new MemoryConnectionRepository();
  c.workspaceRepo = new MemoryWorkspaceRepository();
  c.scenarioRepo = new MemoryScenarioRepository();
  c.configurationRepo = new MemoryConfigurationRepository();
  c.executionRepo = new MemoryExecutionRepository();
  c.deploymentRepo = new MemoryDeploymentRepository();
  c.modelRepo = new MemoryModelRepository();
  c.datasetRepo = new MemoryDatasetRepository();
  c.promptRepo = new MemoryPromptRepository();
  c.promptCollectionRepo = new MemoryPromptCollectionRepository();
  c.resourceGroupRepo = new MemoryResourceGroupRepository();
  c.usageStatisticRepo = new MemoryUsageStatisticRepository();

  // Application use cases
  c.manageConnections = new ManageConnectionsUseCase(c.connectionRepo, c.connectionValidator);
  c.manageWorkspaces = new ManageWorkspacesUseCase(c.workspaceRepo);
  c.manageScenarios = new ManageScenariosUseCase(c.scenarioRepo);
  c.manageConfigurations = new ManageConfigurationsUseCase(c.configurationRepo);
  c.manageExecutions = new ManageExecutionsUseCase(c.executionRepo);
  c.manageDeployments = new ManageDeploymentsUseCase(c.deploymentRepo);
  c.manageModels = new ManageModelsUseCase(c.modelRepo);
  c.manageDatasets = new ManageDatasetsUseCase(c.datasetRepo);
  c.managePrompts = new ManagePromptsUseCase(c.promptRepo, c.promptEnricher);
  c.managePromptCollections = new ManagePromptCollectionsUseCase(c.promptCollectionRepo);
  c.manageResourceGroups = new ManageResourceGroupsUseCase(c.resourceGroupRepo);
  c.getUsageStatistics = new GetUsageStatisticsUseCase(c.usageStatisticRepo);
  c.getCapabilities = new GetCapabilitiesUseCase();

  // Presentation controllers
  c.connectionController = new ConnectionController(c.manageConnections);
  c.workspaceController = new WorkspaceController(c.manageWorkspaces);
  c.scenarioController = new ScenarioController(c.manageScenarios);
  c.configurationController = new ConfigurationController(c.manageConfigurations);
  c.executionController = new ExecutionController(c.manageExecutions);
  c.deploymentController = new DeploymentController(c.manageDeployments);
  c.modelController = new ModelController(c.manageModels);
  c.datasetController = new DatasetController(c.manageDatasets);
  c.promptController = new PromptController(c.managePrompts);
  c.promptCollectionController = new PromptCollectionController(c.managePromptCollections);
  c.resourceGroupController = new ResourceGroupController(c.manageResourceGroups);
  c.statisticsController = new StatisticsController(c.getUsageStatistics);
  c.capabilitiesController = new CapabilitiesController(c.getCapabilities);
  c.healthController = new HealthController("ai-launchpad");

  return c;
}
