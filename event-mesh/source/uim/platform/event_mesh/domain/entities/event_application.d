/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.entities.event_application;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct EventApplication {
    EventApplicationId id;
    TenantId tenantId;
    BrokerServiceId brokerServiceId;
    string name;
    string description;
    EventApplicationStatus status = EventApplicationStatus.registered;
    EventApplicationType applicationType = EventApplicationType.both;
    string applicationDomainId;
    string clientUsername;
    string clientProfile;
    string aclProfile;
    string version_;
    ProtocolType protocol = ProtocolType.smf;
    string publishTopics;
    string subscribeTopics;
    string webhookUrl;
    string webhookAuthToken;
    string maxConnections;
    string currentConnections;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json eventApplicationToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("brokerServiceId", brokerServiceId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("applicationType", applicationType.to!string)
            .set("applicationDomainId", applicationDomainId)
            .set("clientUsername", clientUsername)
            .set("clientProfile", clientProfile)
            .set("aclProfile", aclProfile)
            .set("version", version_)
            .set("protocol", protocol.to!string)
            .set("publishTopics", publishTopics)
            .set("subscribeTopics", subscribeTopics)
            .set("webhookUrl", webhookUrl)
            .set("maxConnections", maxConnections)
            .set("currentConnections", currentConnections)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
