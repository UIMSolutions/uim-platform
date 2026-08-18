/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.event_topics;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageEventTopicsUseCase {

    EventTopic getEventTopic(TenantId tenantId, EventTopicId id);
    EventTopic[] listEventTopics(TenantId tenantId);
    UsecaseResult createEventTopic(EventTopicDTO dto);
    UsecaseResult updateEventTopic(EventTopicDTO dto);
    UsecaseResult deleteEventTopic(TenantId tenantId, EventTopicId id);

}
