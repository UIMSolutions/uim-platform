/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.infrastructure.persistence.repositories.execution_logs;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class ExecutionLogRepository : TenantRepository!(ExecutionLog, ExecutionLogId), IExecutionLogRepository {

  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByWorkflow(tenantId, workflowId).length;
  }

  ExecutionLog[] filterByWorkflow(ExecutionLog[] logs, WorkflowId workflowId, size_t offset = 0, size_t limit = 0) {
    return logs.filter!(e => e.workflowId == workflowId).array.skip(offset).take(limit);
  }

  ExecutionLog[] findByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByTenant(tenantId).filter!(e => e.workflowId == workflowId).array;
  }

  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    findByWorkflow(tenantId, workflowId).each!(e => remove(e));
  }

  size_t countByStep(TenantId tenantId, WorkflowStepId stepId) {
    return findByStep(tenantId, stepId).length;
  }

  ExecutionLog[] filterByStep(ExecutionLog[] logs, WorkflowStepId stepId, size_t offset = 0, size_t limit = 0) {
    return logs.filter!(e => e.stepId == stepId).array.skip(offset).take(limit);
  }

  ExecutionLog[] findByStep(TenantId tenantId, WorkflowStepId stepId) {
    return findByTenant(tenantId).filter!(e => e.stepId == stepId).array;
  }

  void removeByStep(TenantId tenantId, WorkflowStepId stepId) {
    findByTenant(tenantId).filter!(e => !(e.stepId == stepId))
      .each!(e => remove(e));
  }

  size_t countByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    return findByOutcome(tenantId, outcome).length;
  }

  ExecutionLog[] filterByOutcome(ExecutionLog[] logs, ExecutionOutcome outcome, size_t offset = 0, size_t limit = 0) {
    return logs.filter!(e => e.outcome == outcome).array.skip(offset).take(limit);
  }

  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    return findByTenant(tenantId).filter!(e => e.outcome == outcome).array;
  }

  void removeByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    findByTenant(tenantId).filter!(e => !(e.outcome == outcome))
      .each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTimeRange(tenantId, timeFrom, timeTo).length;
  }

  ExecutionLog[] filterByTimeRange(ExecutionLog[] logs, TenantId tenantId, long timeFrom, long timeTo, size_t offset = 0, size_t limit = 0) {
    return logs.filter!((e) {
        if (e.tenantId != tenantId)
          return false;
        if (timeFrom > 0 && e.timestamp < timeFrom)
          return false;
        if (timeTo > 0 && e.timestamp > timeTo)
          return false;
        return true;
      }).array.skip(offset).take(limit);
  }

  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!((e) {
      if (e.tenantId != tenantId)
        return false;
      if (timeFrom > 0 && e.timestamp < timeFrom)
        return false;
      if (timeTo > 0 && e.timestamp > timeTo)
        return false;
      return true;
    }).array;
  }

  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    findByTimeRange(tenantId, timeFrom, timeTo).each!(e => remove(e));
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(e => e.timestamp < beforeTimestamp)
      .each!(e => remove(e));
  }
}
