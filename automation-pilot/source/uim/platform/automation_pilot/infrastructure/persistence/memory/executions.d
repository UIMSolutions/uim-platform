/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.executions;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class MemoryExecutionRepository : TenantRepository!(Execution, ExecutionId), ExecutionRepository {

    // #region ByCommand
    size_t countByCommand(TenantId tenantId, CommandId commandId) {
        return findByCommand(tenantId, commandId).length;
    }

    Execution[] filterByCommand(Execution[] executions, CommandId commandId) {
        return executions.filter!(e => e.commandId == commandId).array;
    }

    Execution[] findByCommand(TenantId tenantId, CommandId commandId) {
        return filterByCommand(find(tenantId), commandId);
    }

    void removeByCommand(TenantId tenantId, CommandId commandId) {
        findByCommand(tenantId, commandId).each!(e => remove(e));
    }
    // #endregion ByCommand

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, ExecutionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Execution[] filterByStatus(Execution[] executions, ExecutionStatus status) {
        return executions.filter!(e => e.status == status).array;
    }

    Execution[] findByStatus(TenantId tenantId, ExecutionStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ExecutionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
