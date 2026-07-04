/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.services.process_validator;
import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
struct ProcessValidator {
    static string validate(TenantId tenantId, ProcessId processId, string name) {
        if (tenantId.isEmpty)
            return "Tenant ID is required";
        if (processId.isEmpty)
            return "Process ID is required";
        if (name.length == 0)
            return "Process name is required";
        if (name.length > 256)
            return "Process name must not exceed 256 characters";
        return "";
    }

    static string validateInstance(TenantId tenantId, ProcessId processId, UserId startedBy) {
        if (tenantId.isEmpty)
            return "Tenant ID is required";
        if (processId.isEmpty)
            return "Process ID is required";
        if (startedBy.isEmpty)
            return "StartedBy user is required";
        return "";
    }

    static string validateTask(TenantId tenantId, TaskId taskId, string name, string assignee) {
        if (tenantId.isEmpty)
            return "Tenant ID is required";
        if (taskId.isEmpty)
            return "Task ID is required";
        if (name.length == 0)
            return "Task name is required";
        if (assignee.length == 0)
            return "Assignee is required";
        return "";
    }
}
