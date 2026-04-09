/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.execution_log;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.execution_log;

// import uim.platform.integration.automation.domain.ports.repositories.execution_logs;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter;
// import std.array : array;

class MemoryExecutionLogRepository : ExecutionLogRepository {
  private ExecutionLog[] store;

  ExecutionLog[] findByWorkflow(WorkflowId workflowtenantId, id tenantId) {
    return store.filter!(e => e.workflowId == workflowId && e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByStep(StepId steptenantId, id tenantId) {
    return store.filter!(e => e.stepId == stepId && e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  ExecutionLog[] findByOutcome(TenantId tenantId, ExecutionOutcome outcome) {
    return store.filter!(e => e.tenantId == tenantId && e.outcome == outcome).array;
  }

  ExecutionLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return store.filter!((e) {
      if (e.tenantId != tenantId)
        return false;
      if (timeFrom > 0 && e.timestamp < timeFrom)
        return false;
      if (timeTo > 0 && e.timestamp > timeTo)
        return false;
      return true;
    }).array;
  }

  long countByWorkflow(WorkflowId workflowtenantId, id tenantId) {
    return cast(long) findByWorkflow(workflowtenantId, id).length;
  }

  void save(ExecutionLog log) {
    store ~= log;
  }

  void removeByWorkflow(WorkflowId workflowtenantId, id tenantId) {
    store = store.filter!(e => !(e.workflowId == workflowId && e.tenantId == tenantId)).array;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
  }
}
