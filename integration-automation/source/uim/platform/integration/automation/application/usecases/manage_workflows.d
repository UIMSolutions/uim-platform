module uim.platform.integration.automation.application.usecases.manage_workflows;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow;
import uim.platform.integration.automation.domain.entities.workflow_step;
import uim.platform.integration.automation.domain.entities.integration_scenario;
// import uim.platform.integration.automation.domain.ports.workflow_repository;
// import uim.platform.integration.automation.domain.ports.step_repository;
// import uim.platform.integration.automation.domain.ports.scenario_repository;
import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation.domain.services.workflow_engine;
import uim.platform.integration.automation.application.dto;

class ManageWorkflowsUseCase {
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
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.scenarioId.length == 0)
      return CommandResult("", "Scenario ID is required");

    // Enforce SAP limit: max 15 active workflows per tenant
    if (engine.isWorkflowLimitReached(req.tenantId))
      return CommandResult("", "Active workflow limit (15) reached for this tenant");

    // Validate scenario exists and is active
    auto scenario = scenarioRepo.findById(req.scenarioId, req.tenantId);
    if (scenario is null)
      return CommandResult("", "Scenario not found");
    if (scenario.status != ScenarioStatus.active)
      return CommandResult("", "Scenario is not active");

    auto now = Clock.currStdTime();

    auto wf = Workflow();
    wf.id = randomUUID().toString();
    wf.tenantId = req.tenantId;
    wf.scenarioId = req.scenarioId;
    wf.name = req.name.length > 0 ? req.name : scenario.name;
    wf.description = req.description.length > 0 ? req.description : scenario.description;
    wf.status = WorkflowStatus.planned;
    wf.currentStepIndex = 0;
    wf.totalSteps = cast(int)scenario.stepTemplates.length;
    wf.completedSteps = 0;
    wf.sourceSystemId = req.sourceSystemId;
    wf.targetSystemId = req.targetSystemId;
    wf.createdBy = req.createdBy;
    wf.createdAt = now;
    wf.updatedAt = now;

    workflowRepo.save(wf);

    // Instantiate workflow steps from scenario templates
    foreach (ref tmpl; scenario.stepTemplates) {
      auto step = WorkflowStep();
      step.id = randomUUID().toString();
      step.workflowId = wf.id;
      step.tenantId = req.tenantId;
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
        step.sourceSystemId = req.sourceSystemId;
      if (tmpl.requiresTargetSystem)
        step.targetSystemId = req.targetSystemId;
      step.estimatedDurationMinutes = tmpl.estimatedDurationMinutes;
      step.createdAt = now;

      // Resolve template dependencies (sequence numbers → step IDs)
      // Dependencies will be resolved by sequence number at runtime
      stepRepo.save(step);
    }

    return CommandResult(wf.id, "");
  }

  Workflow* getWorkflow(WorkflowId id, TenantId tenantId) {
    return workflowRepo.findById(id, tenantId);
  }

  Workflow[] listWorkflows(TenantId tenantId) {
    return workflowRepo.findByTenant(tenantId);
  }

  Workflow[] listByStatus(TenantId tenantId, WorkflowStatus status) {
    return workflowRepo.findByStatus(tenantId, status);
  }

  /// Start a planned workflow.
  CommandResult startWorkflow(WorkflowId id, TenantId tenantId) {
    auto wf = workflowRepo.findById(id, tenantId);
    if (wf is null)
      return CommandResult("", "Workflow not found");
    if (wf.status != WorkflowStatus.planned)
      return CommandResult("", "Workflow is not in planned state");

    wf.status = WorkflowStatus.inProgress;
    wf.startedAt = Clock.currStdTime();
    wf.updatedAt = wf.startedAt;
    workflowRepo.update(*wf);

    engine.advanceWorkflow(id, tenantId);
    return CommandResult(id, "");
  }

  /// Suspend an in-progress workflow.
  CommandResult suspendWorkflow(WorkflowId id, TenantId tenantId) {
    auto wf = workflowRepo.findById(id, tenantId);
    if (wf is null)
      return CommandResult("", "Workflow not found");
    if (wf.status != WorkflowStatus.inProgress)
      return CommandResult("", "Workflow is not in progress");

    wf.status = WorkflowStatus.suspended;
    wf.updatedAt = Clock.currStdTime();
    workflowRepo.update(*wf);
    return CommandResult(id, "");
  }

  /// Resume a suspended workflow.
  CommandResult resumeWorkflow(WorkflowId id, TenantId tenantId) {
    auto wf = workflowRepo.findById(id, tenantId);
    if (wf is null)
      return CommandResult("", "Workflow not found");
    if (wf.status != WorkflowStatus.suspended)
      return CommandResult("", "Workflow is not suspended");

    wf.status = WorkflowStatus.inProgress;
    wf.updatedAt = Clock.currStdTime();
    workflowRepo.update(*wf);

    engine.advanceWorkflow(id, tenantId);
    return CommandResult(id, "");
  }

  /// Terminate a workflow.
  CommandResult terminateWorkflow(WorkflowId id, TenantId tenantId) {
    auto wf = workflowRepo.findById(id, tenantId);
    if (wf is null)
      return CommandResult("", "Workflow not found");
    if (wf.status == WorkflowStatus.completed || wf.status == WorkflowStatus.terminated)
      return CommandResult("", "Workflow is already finished");

    wf.status = WorkflowStatus.terminated;
    wf.completedAt = Clock.currStdTime();
    wf.updatedAt = wf.completedAt;
    workflowRepo.update(*wf);
    return CommandResult(id, "");
  }

  CommandResult deleteWorkflow(WorkflowId id, TenantId tenantId) {
    auto existing = workflowRepo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Workflow not found");

    stepRepo.removeByWorkflow(id, tenantId);
    workflowRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
