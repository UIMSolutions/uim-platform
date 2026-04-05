module uim.platform.process_automation.domain.entities.action;

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.action;

import uim.platform.process_automation.domain.types;

struct ActionParameter {
    string name;
    string type;
    bool required;
    string defaultValue;
    string description;
}

struct ActionHeader {
    string name;
    string value;
}

struct Action {
    ActionId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    ActionStatus status;
    ActionType type;
    HttpMethod method;
    string baseUrl;
    string path;
    ActionHeader[] headers;
    ActionParameter[] inputParameters;
    ActionParameter[] outputParameters;
    string authType;
    string destinationName;
    string version_;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
