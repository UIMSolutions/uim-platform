/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.usertaskfilter;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

struct CreateUserTaskFilterRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the user task filter belongs, which is important for multi-tenancy support and ensuring that the filter is created in the correct context. 
    UserTaskFilterId filterId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a user task filter with the same ID already exists, the service can return the existing filter instead of creating a new one.
    UserId userId; // This is needed to identify the user to which the task filter belongs. This is important for ensuring that the filter is associated with the correct user and for enforcing access control.

    string name; // The name of the user task filter. This is a required field, as it provides a reference to the filter and is often used in filter lists and notifications.
    string description; // A description of the user task filter. This is optional, but it can provide additional context or information about the filter.
    bool isDefault; // Indicates whether this filter is the default filter for the user. This is important for determining which filter to apply when the user does not specify a filter, and for managing the user's filters effectively.
}

struct UpdateUserTaskFilterRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the user task filter belongs, which is important for multi-tenancy support and ensuring that the filter is updated in the correct context.
    UserTaskFilterId filterId; // This is needed to identify which user task filter to update. The client must pass the ID of the filter to be updated.

    string name; // The new name of the user task filter. This field is optional; if the client does not want to update the name, it can be left empty or null.
    string description; // The new description of the user task filter. This field is optional; if the client does not want to update the description, it can be left empty or null.
    bool isDefault; // Indicates whether this filter is the default filter for the user. This field is optional; if the client does not want to update this, it can be left empty or null.
}
