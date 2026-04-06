/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_action;

import uim.platform.situation_automation.domain.types;

struct ApiConfig {
    string baseUrl;
    string path;
    HttpMethod method;
    string authType;
    string destinationName;
    string[][] headers;
    string bodyTemplate;
    int timeoutSeconds;
    int retryCount;
}

struct SituationAction {
    SituationActionId id;
    TenantId tenantId;
    string name;
    string description;
    ActionType type;
    ActionStatus status;
    ApiConfig apiConfig;
    string webhookUrl;
    string emailTemplate;
    string scriptContent;
    string[] applicableTemplateIds;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
    long lastExecutedAt;
    long executionCount;
}
