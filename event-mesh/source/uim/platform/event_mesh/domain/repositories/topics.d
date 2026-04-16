/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface TopicRepository {
    bool existsById(TopicId id);
    Topic findById(TopicId id);

    Topic[] findAll();
    Topic[] findByTenant(TenantId tenantId);
    Topic[] findByBrokerService(BrokerServiceId brokerServiceId);
    Topic[] findByStatus(TopicStatus status);

    void save(Topic topic);
    void update(Topic topic);
    void remove(TopicId id);
}
