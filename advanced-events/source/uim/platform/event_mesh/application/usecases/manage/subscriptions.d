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

    EventSubscription getSubscription(TenantId tenantId, EventSubscriptionId id) {
        return repo.findById(tenantId, id);
    }

    EventSubscription[] listSubscriptions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventSubscription[] listSubscriptions(TenantId tenantId, TopicId topicId) {
        return repo.findByTopic(tenantId, topicId);
    }

    EventSubscription[] listSubscriptions(TenantId tenantId, EventApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createSubscription(SubscriptionDTO dto) {
        EventSubscription subscription;
        subscription.id = dto.subscriptionId;
        subscription.tenantId = dto.tenantId;
        subscription.serviceId = dto.serviceId;
        subscription.topicId = dto.topicId;
        subscription.queueId = dto.queueId;
        subscription.applicationId = dto.applicationId;
        subscription.name = dto.name;
        subscription.description = dto.description;
        subscription.topicFilter = dto.topicFilter;
        subscription.selector = dto.selector;
        subscription.maxRedeliveryCount = dto.maxRedeliveryCount;
        subscription.maxTtl = dto.maxTtl;
        subscription.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidSubscription(subscription))
            return CommandResult(false, "", "Invalid subscription data");

        repo.save(subscription);
        return CommandResult(true, subscription.id.value, "");
    }

    CommandResult updateSubscription(SubscriptionDTO dto) {
        auto subscription = repo.findById(dto.tenantId, dto.subscriptionId);
        if (subscription.isNull)
            return CommandResult(false, "", "Subscription not found");

        if (dto.name.length > 0) subscription.name = dto.name;
        if (dto.description.length > 0) subscription.description = dto.description;
        if (dto.topicFilter.length > 0) subscription.topicFilter = dto.topicFilter;
        if (dto.selector.length > 0) subscription.selector = dto.selector;
        if (!dto.updatedBy.isNull) subscription.updatedBy = dto.updatedBy;

        repo.update(subscription);
        return CommandResult(true, dto.subscriptionId.value, "");
    }

    CommandResult deleteSubscription(TenantId tenantId, EventSubscriptionId id) {
        auto subscription = repo.findById(tenantId, id);
        if (subscription.isNull)
            return CommandResult(false, "", "Subscription not found");

        repo.remove(subscription);
        return CommandResult(true, subscription.id.value, "");
    }
}
