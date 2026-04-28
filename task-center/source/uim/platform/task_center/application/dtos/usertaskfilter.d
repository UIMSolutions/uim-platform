/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.usertaskfilter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CreateUserTaskFilterRequest {
    TenantId tenantId;
    string id;
    string userId;
    string name;
    string description;
    bool isDefault;
}

struct UpdateUserTaskFilterRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    bool isDefault;
}
