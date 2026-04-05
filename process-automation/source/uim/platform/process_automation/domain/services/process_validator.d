/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.services.process_validator;

struct ProcessValidator {
    static string validate(string id, string name) {
        if (id.length == 0)
            return "Process ID is required";
        if (name.length == 0)
            return "Process name is required";
        if (name.length > 256)
            return "Process name must not exceed 256 characters";
        return "";
    }

    static string validateInstance(string processId, string startedBy) {
        if (processId.length == 0)
            return "Process ID is required";
        if (startedBy.length == 0)
            return "StartedBy user is required";
        return "";
    }

    static string validateTask(string name, string assignee) {
        if (name.length == 0)
            return "Task name is required";
        return "";
    }
}
