/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.event_channels;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_status;

@safe:

interface EventChannelRepository : ITenantRepository!(EventChannel, EventChannelId) {
    EventChannel[] findByTopic(TenantId tenantId, EventTopicId topicId);
    EventChannel[] findByStatus(TenantId tenantId, ChannelStatus status);
    bool nameExists(TenantId tenantId, string name);
}
