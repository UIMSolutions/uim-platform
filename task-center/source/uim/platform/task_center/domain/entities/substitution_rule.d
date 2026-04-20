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

    UserId userId;
    UserId substituteId;
    TaskDefinitionId taskDefinitionId;

    SubstitutionStatus status = SubstitutionStatus.pending;

    string startDate;
    string endDate;
    bool isAutoForward;

    Json toJson() const {
        return entityToJson()
            .set("userId", userId.value)
            .set("substituteId", substituteId.value)
            .set("taskDefinitionId", taskDefinitionId.value)
            .set("status", status)
            .set("startDate", startDate)
            .set("endDate", endDate)
            .set("isAutoForward", isAutoForward);
    }
}
