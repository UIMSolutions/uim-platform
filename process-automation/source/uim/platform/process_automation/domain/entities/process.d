/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.process;

import uim.platform.process_automation.domain.types;

struct ProcessStep {
    ProcessStepId id;
    string name;
    StepType type;
    string description;
    string assignee;
    string formId;
    string decisionId;
    string automationId;
    string[] nextSteps;
    string condition;
    int timeoutMinutes;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id.value)
            .set("name", name)
            .set("type", type.toString())
            .set("description", description)
            .set("assignee", assignee)
            .set("formId", formId)
            .set("decisionId", decisionId)
            .set("automationId", automationId)
            .set("nextSteps", nextSteps.array)
            .set("condition", condition)
            .set("timeoutMinutes", timeoutMinutes);

    }
}

struct ProcessVariable {
    string name;
    string type;
    string defaultValue;
    bool required;
    string description;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("type", type)
            .set("defaultValue", defaultValue)
            .set("required", required)
            .set("description", description);
    }
}

struct Process {
    mixin TenantEntity!(ProcessId);

    ProjectId projectId;
    string name;
    string description;
    ProcessStatus status;
    ProcessCategory category;
    string version_;
    ProcessStep[] steps;
    ProcessVariable[] variables;

    Json toJson() const {
        auto j = entityToJson
            .set("projectId", projectId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.toString())
            .set("category", category.toString())
            .set("version", version_)
            .set("steps", steps.map!(step => step.toJson()).array)
            .set("variables", variables.map!(var => var.toJson()).array);

        return j;
    }
}
