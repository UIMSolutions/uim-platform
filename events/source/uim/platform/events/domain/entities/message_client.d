/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.message_client;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

struct MessageClient {
    mixin TenantEntity!MessageClientId;

    MessagingServiceId serviceId;
    string name;
    string description;
    MessageClientStatus status = MessageClientStatus.active;
    MessageClientProtocol protocol = MessageClientProtocol.httprest;
    string xsappname;
    string clientId;
    string clientSecret;
    string tokenUrl;
    string messagingUrls;
    string namespace;
    string certUrl;
    string permittedNamespace;

    Json toJson() const {
        return entityToJson
            .set("serviceId", serviceId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("protocol", protocol.to!string)
            .set("xsappname", xsappname)
            .set("clientId", clientId)
            .set("tokenUrl", tokenUrl)
            .set("messagingUrls", messagingUrls)
            .set("namespace", namespace)
            .set("permittedNamespace", permittedNamespace);
    }
}
