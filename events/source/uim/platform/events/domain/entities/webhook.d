/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct Webhook {
    mixin TenantEntity!WebhookId;

    MessagingServiceId serviceId;
    QueueSubscriptionId subscriptionId;
    string name;
    string description;
    WebhookStatus status = WebhookStatus.active;
    string url;
    string headers;
    bool exemptHandshake = false;
    WebhookAuthType authenticationType = WebhookAuthType.none_;
    string credentialsType;
    string credentialGrant;
    string tokenUrl;
    string clientId;
    string pushInterval;
    WebhookDeliveryMode deliveryMode = WebhookDeliveryMode.atLeastOnce;
    string maxParallelity;

    Json toJson() const {
        return entityToJson
            .set("serviceId", serviceId.value)
            .set("subscriptionId", subscriptionId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("url", url)
            .set("headers", headers)
            .set("exemptHandshake", exemptHandshake)
            .set("authenticationType", authenticationType.to!string)
            .set("credentialsType", credentialsType)
            .set("tokenUrl", tokenUrl)
            .set("pushInterval", pushInterval)
            .set("deliveryMode", deliveryMode.to!string)
            .set("maxParallelity", maxParallelity);
    }
}
