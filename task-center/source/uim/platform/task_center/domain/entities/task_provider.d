/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskProvider {
    mixin TenantEntity!(TaskProviderId);

    string name; // e.g., "Jira", "GitHub", "Custom API"
    string description;
    ProviderType providerType = ProviderType.custom;
    ProviderStatus status = ProviderStatus.inactive;
    AuthenticationType authType = AuthenticationType.oauth2;

    string endpointUrl;
    string authEndpointUrl;
    string clientId;

    string lastSyncAt;
    string lastSyncError;
    long taskCount;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("providerType", providerType.toString())
            .set("status", status.toString())
            .set("authType", authType.toString())
            .set("endpointUrl", endpointUrl)
            .set("authEndpointUrl", authEndpointUrl)
            .set("clientId", clientId)
            .set("lastSyncAt", lastSyncAt)
            .set("lastSyncError", lastSyncError)
            .set("taskCount", taskCount);
    }
}
