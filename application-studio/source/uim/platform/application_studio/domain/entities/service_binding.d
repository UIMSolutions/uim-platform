/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.service_binding;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct ServiceBinding {
    mixin TenantEntity!ServiceBindingId;
    
    DevSpaceId devSpaceId;
    string name;
    string description;
    ServiceProviderType providerType = ServiceProviderType.sapBtp;
    BindingStatus status = BindingStatus.disconnected;
    string serviceUrl;
    string servicePath;
    string authType;
    string credentials;
    string systemAlias;

    Json toJson() const {
        return entityToJson
            .set("devSpaceId", devSpaceId)
            .set("name", name)
            .set("description", description)
            .set("providerType", providerType.to!string)
            .set("status", status.to!string)
            .set("serviceUrl", serviceUrl)
            .set("servicePath", servicePath)
            .set("authType", authType)
            .set("credentials", credentials)
            .set("systemAlias", systemAlias);
    }
}
