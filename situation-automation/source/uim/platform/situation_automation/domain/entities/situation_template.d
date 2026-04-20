/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_template;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct ConditionDefinition {
    string field;
    ConditionOperator operator;
    string value;
    string valueType;

    Json toJson() const {
        return Json.emptyObject
            .set("field", field)
            .set("operator", operator)
            .set("value", value)
            .set("valueType", valueType);
    }
}

struct SituationTemplate {
    mixin TenantEntity!(SituationTemplateId);

    string name;
    string description;
    SituationCategory category;
    SituationSeverity defaultSeverity;
    TemplateStatus status;
    string entityTypeId;
    ConditionDefinition[] conditions;
    string[] suggestedActionIds;
    string sourceSystem;
    string sourceTemplateId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    
    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("category", category.toString())
            .set("defaultSeverity", defaultSeverity.toString())
            .set("status", status.toString())
            .set("entityTypeId", entityTypeId)
            .set("conditions", conditions.map!(c => c.toJson()).array)
            .set("suggestedActionIds", suggestedActionIds)
            .set("sourceSystem", sourceSystem)
            .set("sourceTemplateId", sourceTemplateId)
            .set("autoResolveTimeoutMinutes", autoResolveTimeoutMinutes)
            .set("escalationEnabled", escalationEnabled)
            .set("escalationTargetUserId", escalationTargetUserId);

        return j;
    }
}
