/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.decision;

import uim.platform.process_automation.domain.types;

struct DecisionColumn {
    string id;
    string name;
    string type;
    bool isInput;
    ConditionType conditionType;
    string description;
}

struct DecisionRow {
    string id;
    string[] inputValues;
    string[] outputValues;
    int priority;
}

struct Decision {
    DecisionId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    DecisionStatus status;
    DecisionType type;
    HitPolicy hitPolicy;
    DecisionColumn[] columns;
    DecisionRow[] rows;
    string version_;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
