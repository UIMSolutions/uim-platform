/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageTopicsUseCase { 

    Topic getTopic(TenantId tenantId, TopicId topicId);
    
    Topic[] listTopics(TenantId tenantId);

    Topic[] listTopics(TenantId tenantId, BrokerServiceId serviceId);

    UsecaseResult createTopic(TopicDTO dto);

    UsecaseResult updateTopic(TopicDTO dto);

    UsecaseResult deleteTopic(TenantId tenantId, TopicId topicId);
}

