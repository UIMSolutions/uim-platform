/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.substitution_rule;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

struct SubstitutionRule {
    mixin TenantEntity!(SubstitutionRuleId);

    UserId userId; // The user for whom the substitution rule applies
    UserId substituteId; // The user who will act as a substitute
    TaskDefinitionId definitionId; // The task definition for which the substitution rule applies

    SubstitutionStatus status = SubstitutionStatus.pending; // pending, active, expired

    string startDate; // ISO 8601 format
    string endDate; // ISO 8601 format
    bool isAutoForward; // Whether tasks should be automatically forwarded to the substitute user


    Json toJson() const {
        return entityToJson()
            .set("userId", userId.value)
            .set("substituteId", substituteId.value)
            .set("definitionId", definitionId.value)
            .set("status", status.to!string)
            .set("startDate", startDate)
            .set("endDate", endDate)
            .set("isAutoForward", isAutoForward);
    }
}
