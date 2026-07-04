/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.dtos.dashboard;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

struct CreateDashboardRequest {
    TenantId tenantId;
    DashboardId dashboardId;
    string name;
    string description;
    string type;
    int refreshIntervalSeconds;
    UserId createdBy;
}

struct UpdateDashboardRequest {
    TenantId tenantId;
    DashboardId dashboardId;
    string name;
    string description;
    int refreshIntervalSeconds;
    UserId updatedBy;
}
