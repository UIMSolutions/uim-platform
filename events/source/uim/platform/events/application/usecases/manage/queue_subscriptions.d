/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.queue_subscriptions;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageQueueSubscriptionsUseCase {
    private QueueSubscriptionRepository repo;

    this(QueueSubscriptionRepository repo) { this.repo = repo; }

    QueueSubscription getSubscription(TenantId tenantId, QueueSubscriptionId id) { return repo.findById(tenantId, id); }
    QueueSubscription[] listSubscriptions(TenantId tenantId) { return repo.findByTenant(tenantId); }
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
        auto qs = repo.findById(tenantId, id);
        if (qs.isNull) return CommandResult(false, "", "Queue subscription not found");
        repo.remove(qs);
        return CommandResult(true, qs.id.value, "");
    }
}

///
unittest {
    auto repo = new QueueSubscriptionRepository();
    auto usecase = new ManageQueueSubscriptionsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    QueueSubscriptionDTO createDto;
    createDto.tenantId = tenantId;
    createDto.queueSubscriptionId = QueueSubscriptionId("queueSubscription-1");
    createDto.name = "Test QueueSubscription";
    auto createResult = usecase.createSubscription(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listSubscriptions(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getSubscription(tenantId, QueueSubscriptionId("queueSubscription-1"));
    assert(!item.isNull);

    // Test update
    QueueSubscriptionDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.queueSubscriptionId = QueueSubscriptionId("queueSubscription-1");
    updateDto.name = "Updated QueueSubscription";
    auto updateResult = usecase.updateSubscription(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteSubscription(tenantId, QueueSubscriptionId("queueSubscription-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listSubscriptions(tenantId).length == 0);

}
