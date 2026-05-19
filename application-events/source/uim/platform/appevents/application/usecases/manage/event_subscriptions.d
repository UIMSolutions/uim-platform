/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_subscriptions;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_subscription;
import uim.platform.appevents.domain.repositories.event_subscriptions;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;
import uim.platform.appevents.application.dto;
import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageEventSubscriptionsUseCase {
    private EventSubscriptionRepository _repo;

    this(EventSubscriptionRepository repo) {
        _repo = repo;
    }

    EventSubscription getEventSubscription(TenantId tenantId, EventSubscriptionId id) {
        return _repo.findById(tenantId, id);
    }

    EventSubscription[] listEventSubscriptions(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    EventSubscription[] listByStatus(TenantId tenantId, SubscriptionStatus status) {
        return _repo.findByStatus(tenantId, status);
    }

    CommandResult createEventSubscription(TenantId tenantId, EventSubscriptionDTO dto) {
        if (_repo.nameExists(tenantId, dto.name))
            return CommandResult(false, "Subscription name already exists");
        EventSubscription sub;
        sub.id = EventSubscriptionId(randomUUID().to!string);
        sub.tenantId = tenantId;
        sub.name = dto.name;
        sub.description = dto.description;
        sub.producerSystemId = dto.producerSystemId;
        sub.consumerSystemId = dto.consumerSystemId;
        sub.eventType = dto.eventType;
        sub.status = dto.status;
        sub.formationId = FormationId(dto.formationId);
        sub.filterExpression = dto.filterExpression;
        sub.maxRetries = dto.maxRetries;
        sub.createdAt = Clock.currTime().toUnixTime();
        sub.updatedAt = sub.createdAt;
        _repo.save(tenantId, sub);
        return CommandResult(true, sub.id.value);
    }

    CommandResult updateEventSubscription(TenantId tenantId, EventSubscriptionId id, EventSubscriptionDTO dto) {
        auto sub = _repo.findById(tenantId, id);
        if (sub.id.isNull) return CommandResult(false, "Subscription not found");
        sub.name = dto.name;
        sub.description = dto.description;
        sub.producerSystemId = dto.producerSystemId;
        sub.consumerSystemId = dto.consumerSystemId;
        sub.eventType = dto.eventType;
        sub.status = dto.status;
        sub.formationId = FormationId(dto.formationId);
        sub.filterExpression = dto.filterExpression;
        sub.maxRetries = dto.maxRetries;
        sub.updatedAt = Clock.currTime().toUnixTime();
        _repo.save(tenantId, sub);
        return CommandResult(true, id.value);
    }

    CommandResult deleteEventSubscription(TenantId tenantId, EventSubscriptionId id) {
        auto sub = _repo.findById(tenantId, id);
        if (sub.id.isNull) return CommandResult(false, "Subscription not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
