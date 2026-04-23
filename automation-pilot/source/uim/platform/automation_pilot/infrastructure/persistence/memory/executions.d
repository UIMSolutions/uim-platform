/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryExecutionRepository : TenantRepository!(Execution, ExecutionId),  ExecutionRepository {

    // #region ByCommand
    size_t countByCommand(CommandId commandId) {
        return findByCommand(commandId).length;
    }

    Execution[] findByCommand(CommandId commandId) {
        return findAll().filter!(e => e.commandId == commandId).array;
    }

    void removeByCommand(CommandId commandId) {
        return findByCommand(commandId).each!(e => remove(e));
    }
    // #endregion ByCommand

    // #region ByStatus
    size_t countByStatus(ExecutionStatus status) {
        return findByStatus(status).length;
    }

    Execution[] findByStatus(ExecutionStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(ExecutionStatus status) {
        return findByStatus(status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
