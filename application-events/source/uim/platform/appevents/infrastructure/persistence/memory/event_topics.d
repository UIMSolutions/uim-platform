/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.event_topics;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.domain.repositories.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryEventTopicRepository
    : TenantRepository!(EventTopic, EventTopicId)
    , EventTopicRepository
{
    override EventTopic[] findByStatus(TenantId tenantId, TopicStatus status) {
        return findByTenant(tenantId).filter!(t => t.status == status).array;
    }

    override EventTopic[] findByNamespace(TenantId tenantId, string namespace) {
        return findByTenant(tenantId).filter!(t => t.namespace == namespace).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).filter!(t => t.name == name).array.length > 0;
    }
}
