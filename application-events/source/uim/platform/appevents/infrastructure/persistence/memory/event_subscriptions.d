/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.event_subscriptions;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.event_subscription;
// import uim.platform.appevents.domain.repositories.event_subscriptions;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.subscription_status;
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

class MemoryEventSubscriptionRepository
    : TenantRepository!(EventSubscription, EventSubscriptionId)
    , EventSubscriptionRepository
{
    override EventSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status) {
        return findByTenant(tenantId).filter!(s => s.status == status).array;
    }

    override EventSubscription[] findByProducerSystem(TenantId tenantId, string producerSystemId) {
        return findByTenant(tenantId).filter!(s => s.producerSystemId == producerSystemId).array;
    }

    override EventSubscription[] findByConsumerSystem(TenantId tenantId, string consumerSystemId) {
        return findByTenant(tenantId).filter!(s => s.consumerSystemId == consumerSystemId).array;
    }

    override EventSubscription[] findByFormation(TenantId tenantId, FormationId formationId) {
        return findByTenant(tenantId).filter!(s => s.formationId.value == formationId.value).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).filter!(s => s.name == name).array.length > 0;
    }
}
