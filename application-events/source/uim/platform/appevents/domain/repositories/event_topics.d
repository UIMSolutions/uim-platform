/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.event_topics;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;

@safe:

interface EventTopicRepository : ITentRepository!(EventTopic, EventTopicId) {
    EventTopic[] findByStatus(TenantId tenantId, TopicStatus status);
    EventTopic[] findByNamespace(TenantId tenantId, string namespace);
    bool nameExists(TenantId tenantId, string name);
}
