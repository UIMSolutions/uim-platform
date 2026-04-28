/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.dtos.dto;

import uim.platform.situation_automation.domain.types;





// --- Situation Template ---



// --- Situation Instance ---



// --- Situation Action ---


// --- Automation Rule ---



// --- Entity Type ---



// --- Data Context ---



// --- Notification ---



// --- Dashboard ---

struct CreateDashboardRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string type;
    int refreshIntervalSeconds;
    string createdBy;
}

struct UpdateDashboardRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    int refreshIntervalSeconds;
    string modifiedBy;
}
