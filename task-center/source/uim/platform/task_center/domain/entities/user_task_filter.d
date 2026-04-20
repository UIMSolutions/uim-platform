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

    Json toJson() const {
        return Json.emptyObject
            .set("criterionType", criterionType.to!string)
            .set("value", value);
    }
}

struct UserTaskFilter {
    mixin TenantEntity!(UserTaskFilterId);

    string name;
    string description;
    FilterCriterion[] criteria;
    bool isDefault;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("criteria", criteria.map!(c => c.toJson()).array)
            .set("isDefault", isDefault);
    }
}
