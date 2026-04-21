/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface TopicRepository : ITenantRepository!(Topic, TopicId) {

    size_t countByBrokerService(BrokerServiceId brokerServiceId);
    Topic[] findByBrokerService(BrokerServiceId brokerServiceId);
    void removeByBrokerService(BrokerServiceId brokerServiceId);

    size_t countByStatus(TopicStatus status);
    Topic[] findByStatus(TopicStatus status);
    void removeByStatus(TopicStatus status);

}
