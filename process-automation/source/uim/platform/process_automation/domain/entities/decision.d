/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.decision;

import uim.platform.process_automation.domain.types;

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
            .set("conditionType", conditionType.toString())
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
            .set("inputValues", inputValues)
            .set("outputValues", outputValues)
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
            .set("status", status.toString())
            .set("type", type.toString())
            .set("hitPolicy", hitPolicy.toString())
            .set("columns", columns.map!(col => col.toJson()).array)
            .set("rows", rows.map!(row => row.toJson()).array)
            .set("version", version_);

        return j;
    }
}
