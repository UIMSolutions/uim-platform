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

@safe:

class ManageEventSubscriptionsUseCase {
    private EventSubscriptionRepository repo;

    this(EventSubscriptionRepository repo) { this.repo = repo; }

    EventSubscription getEventSubscription(TenantId tenantId, EventSubscriptionId id) {
        return repo.findById(tenantId, id);
    }

    EventSubscription[] listEventSubscriptions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventSubscription[] listByStatus(TenantId tenantId, SubscriptionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createEventSubscription(EventSubscriptionDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Subscription name already exists");
        EventSubscription sub;
        sub.initEntity(dto.tenantId, dto.createdBy);
        if (!dto.subscriptionId.isNull) sub.id = dto.subscriptionId;
        sub.name = dto.name;
        sub.description = dto.description;
        sub.producerSystemId = dto.producerSystemId;
        sub.consumerSystemId = dto.consumerSystemId;
        sub.eventType = dto.eventType;
        sub.status = dto.status;
        sub.formationId = dto.formationId;
        sub.filterExpression = dto.filterExpression;
        sub.maxRetries = dto.maxRetries;
        repo.save(sub);
        return CommandResult(true, sub.id.value, "");
    }

    CommandResult updateEventSubscription(EventSubscriptionDTO dto) {
        auto sub = repo.findById(dto.tenantId, dto.subscriptionId);
        if (sub.isNull) return CommandResult(false, "", "Subscription not found");
        sub.name = dto.name;
        sub.description = dto.description;
        sub.producerSystemId = dto.producerSystemId;
        sub.consumerSystemId = dto.consumerSystemId;
        sub.eventType = dto.eventType;
        sub.status = dto.status;
        sub.formationId = dto.formationId;
        sub.filterExpression = dto.filterExpression;
        sub.maxRetries = dto.maxRetries;
        if (!dto.updatedBy.isNull) sub.updatedBy = dto.updatedBy;
        repo.update(sub);
        return CommandResult(true, sub.id.value, "");
    }

    CommandResult deleteEventSubscription(TenantId tenantId, EventSubscriptionId id) {
        auto sub = repo.findById(tenantId, id);
        if (sub.isNull) return CommandResult(false, "", "Subscription not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

