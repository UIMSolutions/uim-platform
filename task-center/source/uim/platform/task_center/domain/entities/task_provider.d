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
    TaskProviderId id;
    TenantId tenantId;

    string name;
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

    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
