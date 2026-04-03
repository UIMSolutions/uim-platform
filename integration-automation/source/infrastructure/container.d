module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.scenario_repo;
import uim.platform.xyz.infrastructure.persistence.memory.workflow_repo;
import uim.platform.xyz.infrastructure.persistence.memory.step_repo;
import uim.platform.xyz.infrastructure.persistence.memory.system_repo;
import uim.platform.xyz.infrastructure.persistence.memory.destination_repo;
import uim.platform.xyz.infrastructure.persistence.memory.execution_log_repo;

// Domain Services
import uim.platform.xyz.domain.services.workflow_engine;
import uim.platform.xyz.domain.services.step_executor;

// Use Cases
import uim.platform.xyz.application.usecases.manage_scenarios;
import uim.platform.xyz.application.usecases.manage_workflows;
import uim.platform.xyz.application.usecases.manage_steps;
import uim.platform.xyz.application.usecases.manage_systems;
import uim.platform.xyz.application.usecases.manage_destinations;
import uim.platform.xyz.application.usecases.monitor_executions;

// Controllers
import uim.platform.xyz.presentation.http.scenario;
import uim.platform.xyz.presentation.http.workflow;
import uim.platform.xyz.presentation.http.step;
import uim.platform.xyz.presentation.http.system;
import uim.platform.xyz.presentation.http.destination;
import uim.platform.xyz.presentation.http.monitoring;
import uim.platform.xyz.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryScenarioRepository scenarioRepo;
  MemoryWorkflowRepository workflowRepo;
  MemoryStepRepository stepRepo;
  MemorySystemRepository systemRepo;
  MemoryDestinationRepository destinationRepo;
  MemoryExecutionLogRepository executionLogRepo;

  // Domain services
  WorkflowEngine workflowEngine;
  StepExecutor stepExecutor;

  // Use cases (application layer)
  ManageScenariosUseCase manageScenarios;
  ManageWorkflowsUseCase manageWorkflows;
  ManageStepsUseCase manageSteps;
  ManageSystemsUseCase manageSystems;
  ManageDestinationsUseCase manageDestinations;
  MonitorExecutionsUseCase monitorExecutions;

  // Controllers (driving adapters)
  ScenarioController scenarioController;
  WorkflowController workflowController;
  StepController stepController;
  SystemController systemController;
  DestinationController destinationController;
  MonitoringController monitoringController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters (driven ports)
  c.scenarioRepo = new MemoryScenarioRepository();
  c.workflowRepo = new MemoryWorkflowRepository();
  c.stepRepo = new MemoryStepRepository();
  c.systemRepo = new MemorySystemRepository();
  c.destinationRepo = new MemoryDestinationRepository();
  c.executionLogRepo = new MemoryExecutionLogRepository();

  // Domain services
  c.workflowEngine = new WorkflowEngine(c.workflowRepo, c.stepRepo);
  c.stepExecutor = new StepExecutor(c.stepRepo, c.executionLogRepo);

  // Application use cases
  c.manageScenarios = new ManageScenariosUseCase(c.scenarioRepo);
  c.manageWorkflows = new ManageWorkflowsUseCase(
    c.workflowRepo, c.stepRepo, c.scenarioRepo, c.workflowEngine);
  c.manageSteps = new ManageStepsUseCase(c.stepRepo, c.stepExecutor, c.workflowEngine);
  c.manageSystems = new ManageSystemsUseCase(c.systemRepo);
  c.manageDestinations = new ManageDestinationsUseCase(c.destinationRepo, c.systemRepo);
  c.monitorExecutions = new MonitorExecutionsUseCase(
    c.executionLogRepo, c.workflowRepo, c.stepRepo);

  // Presentation controllers (driving adapters)
  c.scenarioController = new ScenarioController(c.manageScenarios);
  c.workflowController = new WorkflowController(c.manageWorkflows);
  c.stepController = new StepController(c.manageSteps);
  c.systemController = new SystemController(c.manageSystems);
  c.destinationController = new DestinationController(c.manageDestinations);
  c.monitoringController = new MonitoringController(c.monitorExecutions);
  c.healthController = new HealthController("integration-automation");

  return c;
}
