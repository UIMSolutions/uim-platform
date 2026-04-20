/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.automation;

import uim.platform.process_automation.domain.types;

struct AutomationStep {
    AutomationStepId id;
    string name;
    string type;
    string application;
    string activity;
    string[] parameters;
    string[] nextSteps;
    int retryCount;
    int timeoutSeconds;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id.value)
            .set("name", name)
            .set("type", type)
            .set("application", application)
            .set("activity", activity)
            .set("parameters", parameters.array)
            .set("nextSteps", nextSteps.array)
            .set("retryCount", retryCount)
            .set("timeoutSeconds", timeoutSeconds);
    }
}

struct AutomationRun {
    AutomationRunId id;
    AutomationId automationId;
    AutomationRunStatus status;
    string triggeredBy;
    string agentId;
    string inputData;
    string outputData;
    string errorMessage;
    long startedAt;
    long completedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id.value)
            .set("automationId", automationId.value)
            .set("status", status)
            .set("triggeredBy", triggeredBy)
            .set("agentId", agentId)
            .set("inputData", inputData)
            .set("outputData", outputData)
            .set("errorMessage", errorMessage)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt);
    }
}

struct Automation {
    mixin TenantEntity!(AutomationId);

    ProjectId projectId;
    string name;
    string description;
    AutomationStatus status;
    AutomationType type;
    AutomationStep[] steps;
    string targetApplication;
    string version_;

    Json toJson() const {
        return entityToJson
            .set("projectId", projectId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status)
            .set("type", type)
            .set("steps", steps.map!(s => Json.init
                .set("id", s.id.value)
                .set("name", s.name)
                .set("type", s.type)
                .set("application", s.application)
                .set("activity", s.activity)
                .set("parameters", s.parameters.array)
                .set("nextSteps", s.nextSteps.array)
                .set("retryCount", s.retryCount)
                .set("timeoutSeconds", s.timeoutSeconds)).array)
            .set("targetApplication", targetApplication)
            .set("version", version_);
    }
}
