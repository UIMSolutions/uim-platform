/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.manage.workflows;
// import std.uuid;
// import std.datetime.systime : Clock;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow;
// import uim.platform.integration.automation.domain.entities.workflow_step;
// import uim.platform.integration.automation.domain.entities.integration_scenario;
// // import uim.platform.integration.automation.domain.ports.repositories.workflows;
// // import uim.platform.integration.automation.domain.ports.repositories.steps;
// // import uim.platform.integration.automation.domain.ports.repositories.scenarios;
// import uim.platform.integration.automation.domain.ports;
// import uim.platform.integration.automation.domain.services.workflow_engine;
// import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ManageWorkflowsUseCase { // TODO: UIMUseCase {
  private WorkflowRepository workflowRepo;
  private StepRepository stepRepo;
  private ScenarioRepository scenarioRepo;
  private WorkflowEngine engine;

  this(WorkflowRepository workflowRepo, StepRepository stepRepo,
      ScenarioRepository scenarioRepo, WorkflowEngine engine) {
    this.workflowRepo = workflowRepo;
    this.stepRepo = stepRepo;
    this.scenarioRepo = scenarioRepo;
    this.engine = engine;
  }

  /// Create a new workflow instance from a scenario template.
  CommandResult createWorkflow(CreateWorkflowRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.scenarioId.isEmpty)
      return CommandResult(false, "", "Scenario ID is required");

    // Enforce SAP limit: max 15 active workflows per tenant
    if (engine.isWorkflowLimitReached(req.tenantId))
      return CommandResult(false, "", "Active workflow limit (15) reached for this tenant");

    // Validate scenario exists and is active
    auto scenario = scenarioRepo.findById(req.scenarioId, req.tenantId);
    if (scenario.isNull)
      return CommandResult(false, "", "Scenario not found");
    if (scenario.status != ScenarioStatus.active)
      return CommandResult(false, "", "Scenario is not active");

    auto now = currentTimestamp();

    Workflow wf;
    wf.initEntity(req.tenantId, req.createdBy);

    wf.scenarioId = req.scenarioId;
    wf.name = req.name.length > 0 ? req.name : scenario.name;
    wf.description = req.description.length > 0 ? req.description : scenario.description;
    wf.status = WorkflowStatus.planned;
    wf.currentStepIndex = 0;
    wf.totalSteps = cast(int) scenario.stepTemplates.length;
    wf.completedSteps = 0;
    wf.sourceSystemConnectionId = req.sourceSystemConnectionId;
    wf.targetSystemConnectionId = req.targetSystemConnectionId;

    workflowRepo.save(wf);

    // Instantiate workflow steps from scenario templates
    foreach (tmpl; scenario.stepTemplates) {
      WorkflowStep step;
      step.initEntity(req.tenantId);

      step.workflowId = wf.id;
      step.name = tmpl.name;
      step.description = tmpl.description;
      step.type_ = tmpl.type_;
      step.status = StepStatus.pending;
      step.priority = tmpl.priority;
      step.sequenceNumber = tmpl.sequenceNumber;
      step.assignedRole = tmpl.assignedRole;
      step.instructions = tmpl.instructions;
      step.automationEndpoint = tmpl.automationEndpoint;
      step.automationPayload = tmpl.automationPayload;
      if (tmpl.requiresSourceSystem)
        step.sourceSystemConnectionId = req.sourceSystemConnectionId;
      if (tmpl.requiresTargetSystem)
        step.targetSystemConnectionId = req.targetSystemConnectionId;
      step.estimatedDurationMinutes = tmpl.estimatedDurationMinutes;

      // Resolve template dependencies (sequence numbers → step IDs)
      // Dependencies will be resolved by sequence number at runtime
      stepRepo.save(step);
    }

    return CommandResult(true, wf.id.value, "");
  }

  Workflow getWorkflow(TenantId tenantId, WorkflowId id) {
    return workflowRepo.findById(tenantId, id);
  }

  Workflow[] listWorkflows(TenantId tenantId) {
    return workflowRepo.findByTenant(tenantId);
  }

  Workflow[] listByStatus(TenantId tenantId, WorkflowStatus status) {
    return workflowRepo.findByStatus(tenantId, status);
  }

  /// Start a planned workflow.
  CommandResult startWorkflow(TenantId tenantId, WorkflowId id) {
    auto wf = workflowRepo.findById(tenantId, id);
    if (wf.isNull)
      return CommandResult(false, "", "Workflow not found");
    if (wf.status != WorkflowStatus.planned)
      return CommandResult(false, "", "Workflow is not in planned state");

    wf.status = WorkflowStatus.inProgress;
    wf.startedAt = currentTimestamp();
    wf.updatedAt = wf.startedAt;
    workflowRepo.update(wf);

    engine.advanceWorkflow(tenantId, id);
    return CommandResult(true, id.value, "");
  }

  /// Suspend an in-progress workflow.
  CommandResult suspendWorkflow(TenantId tenantId, WorkflowId id) {
    auto wf = workflowRepo.findById(tenantId, id);
    if (wf.isNull)
      return CommandResult(false, "", "Workflow not found");
    if (wf.status != WorkflowStatus.inProgress)
      return CommandResult(false, "", "Workflow is not in progress");

    wf.status = WorkflowStatus.suspended;
    wf.updatedAt = currentTimestamp();
    workflowRepo.update(wf);
    return CommandResult(true, id.value, "");
  }

  /// Resume a suspended workflow.
  CommandResult resumeWorkflow(TenantId tenantId, WorkflowId id) {
    auto wf = workflowRepo.findById(tenantId, id);
    if (wf.isNull)
      return CommandResult(false, "", "Workflow not found");
    if (wf.status != WorkflowStatus.suspended)
      return CommandResult(false, "", "Workflow is not suspended");

    wf.status = WorkflowStatus.inProgress;
    wf.updatedAt = currentTimestamp();
    workflowRepo.update(wf);

    engine.advanceWorkflow(tenantId, id);
    return CommandResult(true, id.value, "");
  }

  /// Terminate a workflow.
  CommandResult terminateWorkflow(TenantId tenantId, WorkflowId id) {
    auto wf = workflowRepo.findById(tenantId, id);
    if (wf.isNull)
      return CommandResult(false, "", "Workflow not found");
    if (wf.status == WorkflowStatus.completed || wf.status == WorkflowStatus.terminated)
      return CommandResult(false, "", "Workflow is already finished");

    wf.status = WorkflowStatus.terminated;
    wf.completedAt = currentTimestamp();
    wf.updatedAt = wf.completedAt;
    workflowRepo.update(wf);
    return CommandResult(true, id.value, "");
  }

  CommandResult deleteWorkflow(TenantId tenantId, WorkflowId id) {
    auto existing = workflowRepo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Workflow not found");

    stepRepo.removeByWorkflow(tenantId, id);

    workflowRepo.remove(existing);
    return CommandResult(true, id.value, "");
  }
}
