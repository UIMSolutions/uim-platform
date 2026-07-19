/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.message_binding;

import uim.platform.events;
mixin(ShowModule!());

@safe:

struct MessageBinding {
    mixin TenantEntity!MessageBindingId;

    MessageClientId clientId;
    MessagingServiceId serviceId;
    QueueId queueId;
    EventChannelId channelId;
    string name;
    string description;
    MessageBindingStatus status = MessageBindingStatus.active;
    MessageBindingPermission permission = MessageBindingPermission.publishSubscribe;
    string bindingType;

    Json toJson() const {
        return entityToJson
            .set("clientId", clientId.value)
            .set("serviceId", serviceId.value)
            .set("queueId", queueId.value)
            .set("channelId", channelId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("permission", permission.to!string)
            .set("bindingType", bindingType);
    }
}
