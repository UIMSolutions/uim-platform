/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.entities.data_quality_rule;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

struct DataQualityRule {
    mixin TenantEntity!(DataQualityRuleId);

    string name;
    string description;
    string fieldName;
    string fieldPath;
    RuleType ruleType = RuleType.required;
    RuleSeverity severity = RuleSeverity.error;
    string condition;
    string errorMessage;
    string bpCategory;
    bool isActive = true;
    int weight = 10;
    string validValues;
    string regexPattern;
    string minValue;
    string maxValue;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("fieldName", fieldName)
            .set("fieldPath", fieldPath)
            .set("ruleType", ruleType.to!string)
            .set("severity", severity.to!string)
            .set("condition", condition)
            .set("errorMessage", errorMessage)
            .set("bpCategory", bpCategory)
            .set("isActive", isActive)
            .set("weight", weight)
            .set("validValues", validValues)
            .set("regexPattern", regexPattern)
            .set("minValue", minValue)
            .set("maxValue", maxValue);
    }
}
