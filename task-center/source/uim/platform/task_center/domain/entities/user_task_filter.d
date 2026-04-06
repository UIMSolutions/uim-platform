/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.user_task_filter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct FilterCriterion {
    FilterCriterionType criterionType;
    string value;
}

struct UserTaskFilter {
    UserTaskFilterId id;
    TenantId tenantId;
    UserId userId;

    string name;
    string description;
    FilterCriterion[] criteria;
    bool isDefault;

    string createdAt;
    string modifiedAt;
}
