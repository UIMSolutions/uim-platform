/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.decision;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

struct DecisionColumn {
    DecisionColumnId decisionColumnId;
    string name;
    string type;
    bool isInput;
    ConditionType conditionType;
    string description;

    Json toJson() const {
        return Json.emptyObject
            .set("decisionColumnId", decisionColumnId.value)
            .set("name", name)
            .set("type", type)
            .set("isInput", isInput)
            .set("conditionType", conditionType.to!string())
            .set("description", description);
    }
}

struct DecisionRow {
    DecisionRowId decisionRowId;
    string[] inputValues;
    string[] outputValues;
    int priority;

    Json toJson() const {
        return Json.emptyObject
            .set("decisionRowId", decisionRowId.value)
            .set("inputValues", inputValues.toJson())
            .set("outputValues", outputValues.toJson())
            .set("priority", priority);
    }
}

struct Decision {
    mixin TenantEntity!(DecisionId);

    ProjectId projectId;
    string name;
    string description;
    DecisionStatus status;
    DecisionType type;
    HitPolicy hitPolicy;
    DecisionColumn[] columns;
    DecisionRow[] rows;
    string version_;

    Json toJson() const {
        auto j = entityToJson
            .set("projectId", projectId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string())
            .set("type", type.to!string())
            .set("hitPolicy", hitPolicy.to!string())
            .set("columns", columns.map!(col => col.toJson()).array.toJson)
            .set("rows", rows.map!(row => row.toJson()).array.toJson)
            .set("version", version_);

        return j;
    }
}
