/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.container;

// import uim.platform.process_automation.infrastructure.config;

// // Repositories
// import uim.platform.process_automation.infrastructure.persistence.memory.processes;
// import uim.platform.process_automation.infrastructure.persistence.memory.process_instances;
// import uim.platform.process_automation.infrastructure.persistence.memory.tasks;
// import uim.platform.process_automation.infrastructure.persistence.memory.decisions;
// import uim.platform.process_automation.infrastructure.persistence.memory.forms;
// import uim.platform.process_automation.infrastructure.persistence.memory.automations;
// import uim.platform.process_automation.infrastructure.persistence.memory.triggers;
// import uim.platform.process_automation.infrastructure.persistence.memory.actions;
// import uim.platform.process_automation.infrastructure.persistence.memory.visibilities;
// import uim.platform.process_automation.infrastructure.persistence.memory.artifacts;

// // Use Cases
// import uim.platform.process_automation.application.usecases.manage.processes;
// import uim.platform.process_automation.application.usecases.manage.process_instances;
// import uim.platform.process_automation.application.usecases.manage.tasks;
// import uim.platform.process_automation.application.usecases.manage.decisions;
// import uim.platform.process_automation.application.usecases.manage.forms;
// import uim.platform.process_automation.application.usecases.manage.automations;
// import uim.platform.process_automation.application.usecases.manage.triggers;
// import uim.platform.process_automation.application.usecases.manage.actions;
// import uim.platform.process_automation.application.usecases.manage.visibilities;
// import uim.platform.process_automation.application.usecases.manage.artifacts;

// // Controllers
// import uim.platform.process_automation.presentation.http.controllers.process;
// import uim.platform.process_automation.presentation.http.controllers.process_instance;
// import uim.platform.process_automation.presentation.http.controllers.task;
// import uim.platform.process_automation.presentation.http.controllers.decision;
// import uim.platform.process_automation.presentation.http.controllers.form;
// import uim.platform.process_automation.presentation.http.controllers.automation;
// import uim.platform.process_automation.presentation.http.controllers.trigger;
// import uim.platform.process_automation.presentation.http.controllers.action;
// import uim.platform.process_automation.presentation.http.controllers.visibility;
// import uim.platform.process_automation.presentation.http.controllers.artifact;
// import uim.platform.process_automation.presentation.http.controllers.health;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct Container {
    // Repositories (driven adapters)
    MemoryProcessRepository processRepo;
    MemoryProcessInstanceRepository processInstanceRepo;
    MemoryTaskRepository taskRepo;
    MemoryDecisionRepository decisionRepo;
    MemoryFormRepository formRepo;
    MemoryAutomationRepository automationRepo;
    MemoryTriggerRepository triggerRepo;
    MemoryActionRepository actionRepo;
    MemoryVisibilityRepository visibilityRepo;
    MemoryArtifactRepository artifactRepo;

    // Use cases (application layer)
    ManageProcessesUseCase manageProcesses;
    ManageProcessInstancesUseCase manageProcessInstances;
    ManageTasksUseCase manageTasks;
    ManageDecisionsUseCase manageDecisions;
    ManageFormsUseCase manageForms;
    ManageAutomationsUseCase manageAutomations;
    ManageTriggersUseCase manageTriggers;
    ManageActionsUseCase manageActions;
    ManageVisibilitiesUseCase manageVisibilities;
    ManageArtifactsUseCase manageArtifacts;

    // Controllers (driving adapters)
    ProcessController processController;
    ProcessInstanceController processInstanceController;
    TaskController taskController;
    DecisionController decisionController;
    FormController formController;
    AutomationController automationController;
    TriggerController triggerController;
    ActionController actionController;
    VisibilityController visibilityController;
    ArtifactController artifactController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.processRepo = new MemoryProcessRepository();
    c.processInstanceRepo = new MemoryProcessInstanceRepository();
    c.taskRepo = new MemoryTaskRepository();
    c.decisionRepo = new MemoryDecisionRepository();
    c.formRepo = new MemoryFormRepository();
    c.automationRepo = new MemoryAutomationRepository();
    c.triggerRepo = new MemoryTriggerRepository();
    c.actionRepo = new MemoryActionRepository();
    c.visibilityRepo = new MemoryVisibilityRepository();
    c.artifactRepo = new MemoryArtifactRepository();

    // Application use cases
    c.manageProcesses = new ManageProcessesUseCase(c.processRepo);
    c.manageProcessInstances = new ManageProcessInstancesUseCase(c.processInstanceRepo);
    c.manageTasks = new ManageTasksUseCase(c.taskRepo);
    c.manageDecisions = new ManageDecisionsUseCase(c.decisionRepo);
    c.manageForms = new ManageFormsUseCase(c.formRepo);
    c.manageAutomations = new ManageAutomationsUseCase(c.automationRepo);
    c.manageTriggers = new ManageTriggersUseCase(c.triggerRepo);
    c.manageActions = new ManageActionsUseCase(c.actionRepo);
    c.manageVisibilities = new ManageVisibilitiesUseCase(c.visibilityRepo);
    c.manageArtifacts = new ManageArtifactsUseCase(c.artifactRepo);

    // Presentation controllers
    c.processController = new ProcessController(c.manageProcesses);
    c.processInstanceController = new ProcessInstanceController(c.manageProcessInstances);
    c.taskController = new TaskController(c.manageTasks);
    c.decisionController = new DecisionController(c.manageDecisions);
    c.formController = new FormController(c.manageForms);
    c.automationController = new AutomationController(c.manageAutomations);
    c.triggerController = new TriggerController(c.manageTriggers);
    c.actionController = new ActionController(c.manageActions);
    c.visibilityController = new VisibilityController(c.manageVisibilities);
    c.artifactController = new ArtifactController(c.manageArtifacts);
    c.healthController = new HealthController("process-automation");

    return c;
}
