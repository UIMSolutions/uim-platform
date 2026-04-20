/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_instance;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct ResolutionInfo {
    ResolutionType type;
    string resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
    long resolvedAt;
}

struct SituationInstance {
    mixin TenantEntity!(SituationInstanceId);

    SituationTemplateId templateId;
    string description;
    InstanceStatus status;
    SituationSeverity severity;
    string entityId;
    string entityTypeId;
    string[][] contextData;
    ResolutionInfo resolution;
    string assignedTo;
    string sourceSystem;
    string sourceInstanceId;
    int retryCount;
    long detectedAt;
    long dueAt;
    
    Json toJson() const {
        auto j = entityToJson
            .set("templateId", templateId.value)
            .set("description", description)
            .set("status", status)
            .set("severity", severity)
            .set("entityId", entityId)
            .set("entityTypeId", entityTypeId)
            .set("contextData", contextData.map!(cd => cd.array).array)
            .set("resolution", resolution.type != ResolutionType.none ? Json.init
                .set("type", resolution.type)
                .set("resolvedBy", resolution.resolvedBy)
                .set("actionId", resolution.actionId)
                .set("ruleId", resolution.ruleId)
                .set("outcome", resolution.outcome)
                .set("resolvedAt", resolution.resolvedAt) : Json(null))
            .set("assignedTo", assignedTo)
            .set("sourceSystem", sourceSystem)
            .set("sourceInstanceId", sourceInstanceId)
            .set("retryCount", retryCount)
            .set("detectedAt", detectedAt)
            .set("dueAt", dueAt);

        return j;
    }
}
