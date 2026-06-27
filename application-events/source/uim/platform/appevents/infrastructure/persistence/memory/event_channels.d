/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.event_channels;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;
import uim.platform.appevents.domain.repositories.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_status;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryEventChannelRepository
    : TenantRepository!(EventChannel, EventChannelId)
    , EventChannelRepository
{
    override EventChannel[] findByTopic(TenantId tenantId, EventTopicId topicId) {
        return findByTenant(tenantId).filter!(c => c.topicId.value == topicId.value).array;
    }

    override EventChannel[] findByStatus(TenantId tenantId, ChannelStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).filter!(c => c.name == name).array.length > 0;
    }
}
