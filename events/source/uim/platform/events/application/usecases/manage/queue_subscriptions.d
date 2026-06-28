/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.queue_subscriptions;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class ManageQueueSubscriptionsUseCase {
    private QueueSubscriptionRepository repo;

    this(QueueSubscriptionRepository repo) { this.repo = repo; }

    QueueSubscription getSubscription(TenantId tenantId, QueueSubscriptionId id) { return repo.find(tenantId, id); }
    QueueSubscription[] listSubscriptions(TenantId tenantId) { return repo.find(tenantId); }
    QueueSubscription[] listByQueue(TenantId tenantId, QueueId queueId) { return repo.findByQueue(tenantId, queueId); }
    QueueSubscription[] listByService(TenantId tenantId, MessagingServiceId serviceId) { return repo.findByService(tenantId, serviceId); }

    CommandResult createSubscription(QueueSubscriptionDTO dto) {
        QueueSubscription qs;
        qs.id = dto.subscriptionId;
        qs.tenantId = dto.tenantId;
        qs.queueId = dto.queueId;
        qs.serviceId = dto.serviceId;
        qs.name = dto.name;
        qs.description = dto.description;
        qs.topicPattern = dto.topicPattern;
        qs.namespace = dto.namespace;
        qs.createdBy = dto.createdBy;
        if (!EventsValidator.isValidQueueSubscription(qs))
            return CommandResult(false, "", "Invalid queue subscription data");
        repo.save(qs);
        return CommandResult(true, qs.id.value, "");
    }

    CommandResult updateSubscription(QueueSubscriptionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.subscriptionId);
        if (existing.isNull) return CommandResult(false, "", "Queue subscription not found");
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.topicPattern.length > 0) existing.topicPattern = dto.topicPattern;
        if (dto.namespace.length > 0) existing.namespace = dto.namespace;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSubscription(TenantId tenantId, QueueSubscriptionId id) {
        auto qs = repo.find(tenantId, id);
        if (qs.isNull) return CommandResult(false, "", "Queue subscription not found");
        repo.remove(qs);
        return CommandResult(true, qs.id.value, "");
    }
}
