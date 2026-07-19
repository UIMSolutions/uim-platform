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
    FilterCriterionType criterionType; // Type of criterion (e.g., Status, Priority, Assignee)
    string value; // Value for the criterion (e.g., "pending", "high", "currentUser")

    Json toJson() const {
        return Json.emptyObject
            .set("criterionType", criterionType.to!string)
            .set("value", value);
    }
}
    
struct UserTaskFilter {
    mixin TenantEntity!(UserTaskFilterId);

    string name; // Name of the filter (e.g., "My Tasks", "High Priority", "Pending Approvals")
    string description; // Optional description of the filter's purpose or criteria
    FilterCriterion[] criteria; // List of criteria that define the filter (e.g., status = "pending", priority = "high", assignee = "currentUser")
    bool isDefault; // Indicates whether this filter is the default filter for the user (only one default filter per user)
    UserId userId; // The user to whom this filter belongs

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("criteria", criteria.map!(c => c.toJson()).array.toJson)
            .set("isDefault", isDefault)
            .set("userId", userId.value);
    }
}
