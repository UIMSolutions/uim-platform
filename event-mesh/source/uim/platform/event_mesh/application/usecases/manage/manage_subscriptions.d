/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_subscriptions;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageSubscriptionsUseCase : UIMUseCase {
    private SubscriptionRepository repo;

    this(SubscriptionRepository repo) {
        this.repo = repo;
    }

    EventSubscription* get_(SubscriptionId id) {
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
        s.id = SubscriptionId(dto.id);
        s.tenantId = dto.tenantId;
        s.brokerServiceId = BrokerServiceId(dto.brokerServiceId);
        s.topicId = TopicId(dto.topicId);
        s.queueId = QueueId(dto.queueId);
        s.applicationId = EventApplicationId(dto.applicationId);
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
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(SubscriptionDTO dto) {
        auto existing = repo.findById(SubscriptionId(dto.id));
        if (existing is null)
            return CommandResult(false, "", "Subscription not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.topicFilter.length > 0) existing.topicFilter = dto.topicFilter;
        if (dto.selector.length > 0) existing.selector = dto.selector;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(SubscriptionId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Subscription not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
