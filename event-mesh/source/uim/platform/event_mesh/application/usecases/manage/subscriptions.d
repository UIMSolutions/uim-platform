/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageSubscriptionsUseCase { // TODO: UIMUseCase {
    private SubscriptionRepository repo;

    this(SubscriptionRepository repo) {
        this.repo = repo;
    }

    EventSubscription getById(EventSubscriptionId id) {
        return repo.findById(id);
    }

    EventSubscription[] list() {
        return repo.findAll();
    }

    EventSubscription[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventSubscription[] listByTopic(TopicId topicId) {
        return repo.findByTopic(topicId);
    }

    EventSubscription[] listByApplication(EventApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(SubscriptionDTO dto) {
        EventSubscription s;
        s.id = dto.eventSubscriptionId;
        s.tenantId = dto.tenantId;
        s.brokerServiceId = dto.brokerServiceId;
        s.topicId = dto.topicId;
        s.queueId = dto.queueId;
        s.applicationId = dto.publisherId;
        s.name = dto.name;
        s.description = dto.description;
        s.topicFilter = dto.topicFilter;
        s.selector = dto.selector;
        s.maxRedeliveryCount = dto.maxRedeliveryCount;
        s.maxTtl = dto.maxTtl;
        s.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidSubscription(s))
            return CommandResult(false, "", "Invalid subscription data");
        repo.save(s);
        return CommandResult(true, s.id.value, "");
    }

    CommandResult update(SubscriptionDTO dto) {
        auto existing = repo.findById(dto.eventSubscriptionId);
        if (existing.isNull)
            return CommandResult(false, "", "Subscription not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.topicFilter.length > 0) existing.topicFilter = dto.topicFilter;
        if (dto.selector.length > 0) existing.selector = dto.selector;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.eventSubscriptionId.value, "");
    }

    CommandResult remove(EventSubscriptionId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Subscription not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
