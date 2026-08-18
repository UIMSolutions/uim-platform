/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.executions;
// import uim.platform.ai_launchpad.domain.ports.executionssitories.executions;
// import uim.platform.ai_launchpad.domain.entities.execution : Execution;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;


import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageExecutionsUseCase {
  protected IExecutionRepository executions;

  this(IExecutionRepository executions) {
    this.executions = executions;
  }

  UsecaseResult createExecution(CreateExecutionRequest r) {
    auto e = Execution(r.tenantId, r.executionId.isNull ? ExecutionId(createId()) : r.executionId); // , r.createdBy);
    e.connectionId = r.connectionId;
    e.configurationId = r.configurationId;
    e.resourceGroupId = r.resourceGroupId;
    e.status = ExecutionStatus.pending;

    executions.save(e);
    return UsecaseResult(true, e.id.value, "");
  }

  Execution getExecution(TenantId tenantId, ConnectionId connectionId, ExecutionId id) {
    return executions.findById(tenantId, connectionId, id);
  }

  Execution[] listExecutions(TenantId tenantId, ConnectionId connectionId) {
    return executions.findByConnection(tenantId, connectionId);
  }

  Execution[] listExecutions(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return executions.findByScenario(tenantId, connectionId, scenarioId);
  }

  UsecaseResult patchExecution(PatchExecutionRequest r) {
    auto e = executions.findById(r.tenantId, r.connectionId, r.executionId);
    if (e.isNull)
      return UsecaseResult(false, "", "Execution not found");
    e.targetStatus = r.targetStatus;
    if (r.targetStatus == "stopped")
      e.status = ExecutionStatus.stopped;
    else if (r.targetStatus == "deleted")
      e.status = ExecutionStatus.dead;
    e.updatedAt = currentTimestamp();

    executions.save(e);
    return UsecaseResult(true, e.id.value, "");
  }

  UsecaseResult[] bulkPatchExecution(BulkPatchExecutionRequest r) {
    UsecaseResult[] results;
    foreach (eid; r.executionIds) {
      PatchExecutionRequest pr;
      pr.tenantId = r.tenantId;
      pr.connectionId = r.connectionId;
      pr.executionId = eid;
      pr.targetStatus = r.targetStatus;
      results ~= patchExecution(pr);
    }
    return results;
  }

  UsecaseResult deleteExecution(TenantId tenantId, ConnectionId connectionId, ExecutionId id) {
    auto execution = executions.findById(tenantId, connectionId, id);
    if (execution.isNull)
      return UsecaseResult(false, "", "Execution not found");

    executions.remove(execution);
    return UsecaseResult(true, execution.id.value, "");
  }
}
