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
    UserId resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
    long resolvedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("type", type.to!string())
            .set("resolvedBy", resolvedBy)
            .set("actionId", actionId)
            .set("ruleId", ruleId)
            .set("outcome", outcome)
            .set("resolvedAt", resolvedAt);
    }
}

struct SituationInstance {
    mixin TenantEntity!(SituationInstanceId);

    SituationTemplateId situationTemplateId;
    string description;
    InstanceStatus status;
    SituationSeverity severity;
    string entityId;
    EntityTypeId entityTypeId;
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
            .set("situationTemplateId", situationTemplateId.value)
            .set("description", description)
            .set("status", status.to!string())
            .set("severity", severity.to!string())
            .set("entityId", entityId)
            .set("entityTypeId", entityTypeId.value)
            .set("contextData", contextData.map!(cd => cd.array.toJson).array.toJson)
            .set("resolution", resolution.toJson())
            .set("assignedTo", assignedTo)
            .set("sourceSystem", sourceSystem)
            .set("sourceInstanceId", sourceInstanceId)
            .set("retryCount", retryCount)
            .set("detectedAt", detectedAt)
            .set("dueAt", dueAt);

        return j;
    }
}
