module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_scenario_repo;
import infrastructure.persistence.in_memory_workflow_repo;
import infrastructure.persistence.in_memory_step_repo;
import infrastructure.persistence.in_memory_system_repo;
import infrastructure.persistence.in_memory_destination_repo;
import infrastructure.persistence.in_memory_execution_log_repo;

// Domain Services
import domain.services.workflow_engine;
import domain.services.step_executor;

// Use Cases
import application.use_cases.manage_scenarios;
import application.use_cases.manage_workflows;
import application.use_cases.manage_steps;
import application.use_cases.manage_systems;
import application.use_cases.manage_destinations;
import application.use_cases.monitor_executions;

// Controllers
import presentation.http.scenario_controller;
import presentation.http.workflow_controller;
import presentation.http.step_controller;
import presentation.http.system_controller;
import presentation.http.destination_controller;
import presentation.http.monitoring_controller;
import presentation.http.health_controller;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryScenarioRepository scenarioRepo;
    InMemoryWorkflowRepository workflowRepo;
    InMemoryStepRepository stepRepo;
    InMemorySystemRepository systemRepo;
    InMemoryDestinationRepository destinationRepo;
    InMemoryExecutionLogRepository executionLogRepo;

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
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters (driven ports)
    c.scenarioRepo = new InMemoryScenarioRepository();
    c.workflowRepo = new InMemoryWorkflowRepository();
    c.stepRepo = new InMemoryStepRepository();
    c.systemRepo = new InMemorySystemRepository();
    c.destinationRepo = new InMemoryDestinationRepository();
    c.executionLogRepo = new InMemoryExecutionLogRepository();

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
    c.healthController = new HealthController();

    return c;
}
