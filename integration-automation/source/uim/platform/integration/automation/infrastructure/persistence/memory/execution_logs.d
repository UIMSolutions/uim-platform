/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.execution_log;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.execution_log;

// // import uim.platform.integration.automation.domain.ports.repositories.execution_logs;
// import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:;

class MemoryExecutionLogRepository : TenantRepository!(ExecutionLog, ExecutionLogId), ExecutionLogRepository {


  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByWorkflow(tenantId, workflowId).length;
  }
  ExecutionLog[] filterByWorkflow(ExecutionLog[] logs, TenantId tenantId, WorkflowId workflowId, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? logs.filter!(e => e.workflowId == workflowId && e.tenantId == tenantId).skip(offset).array
        : logs.filter!(e => e.workflowId == workflowId && e.tenantId == tenantId).skip(offset).take(limit).array;
  }
  ExecutionLog[] findByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByTenant(tenantId).filter!(e => e.workflowId == workflowId && e.tenantId == tenantId).array;
  }
  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    store = findAll().filter!(e => !(e.workflowId == workflowId && e.tenantId == tenantId)).array;
  }

  size_t countByStep(TenantId tenantId, StepId stepId) {
    return findByStep(tenantId, stepId).length;
  }
  ExecutionLog[] filterByStep(ExecutionLog[] logs, TenantId tenantId, StepId stepId, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? logs.filter!(e => e.stepId == stepId && e.tenantId == tenantId).skip(offset).array
        : logs.filter!(e => e.stepId == stepId && e.tenantId == tenantId).skip(offset).take(limit).array;
  }
  ExecutionLog[] findByStep(TenantId tenantId, StepId stepId) {
    return findByTenant(tenantId).filter!(e => e.stepId == stepId && e.tenantId == tenantId).array;
  }
  void removeByStep(TenantId tenantId, StepId stepId) {
    findByTenant(tenantId).filter!(e => !(e.stepId == stepId)).each!(e => remove(e));
  }
  
  size_t countByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    return findByOutcome(tenantId, outcome).length;
  }
  ExecutionLog[] filterByOutcome(ExecutionLog[] logs, TenantId tenantId, ExecutionOutcome outcome, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? logs.filter!(e => e.outcome == outcome && e.tenantId == tenantId).skip(offset).array
        : logs.filter!(e => e.outcome == outcome && e.tenantId == tenantId).skip(offset).take(limit).array;
  }
  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    return findByTenant(tenantId).filter!(e => e.outcome == outcome).array;
  }
  void removeByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    findByTenant(tenantId).filter!(e => !(e.outcome == outcome)).each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTimeRange(tenantId, timeFrom, timeTo).length;
  }
  ExecutionLog[] filterByTimeRange(ExecutionLog[] logs, TenantId tenantId, long timeFrom, long timeTo, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
        ? logs.filter!((e) {
          if (e.tenantId != tenantId)
            return false;
          if (timeFrom > 0 && e.timestamp < timeFrom)
            return false;
          if (timeTo > 0 && e.timestamp > timeTo)
            return false;
          return true;
        }).skip(offset).array
        : logs.filter!((e) {
          if (e.tenantId != tenantId)
            return false;
          if (timeFrom > 0 && e.timestamp < timeFrom)
            return false;
          if (timeTo > 0 && e.timestamp > timeTo)
            return false;
          return true;
        }).skip(offset).take(limit).array;
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


  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(e => !(e.timestamp < beforeTimestamp)).each!(e => remove(e));
  }
}
