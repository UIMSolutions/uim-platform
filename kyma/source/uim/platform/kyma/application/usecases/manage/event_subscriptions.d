/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.event_subscriptions;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.event_subscription;
// import uim.platform.kyma.domain.ports.repositories.event_subscriptions;

import uim.platform.kyma;

// mixin(ShowModule!());

@safe:
/// Application service for event subscription management.
class ManageEventSubscriptionsUseCase { // TODO: UIMUseCase {
  private EventSubscriptionRepository subscriptionRepository;

  this(EventSubscriptionRepository subscriptionRepository) {
    this.subscriptionRepository = subscriptionRepository;
  }

  CommandResult createEventSubscription(CreateEventSubscriptionRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Subscription name is required");
    if (req.source.length == 0)
      return CommandResult(false, "", "Event source is required");
    if (req.eventTypes.length == 0)
      return CommandResult(false, "", "At least one event type is required");

    if (subscriptionRepository.existsByName(req.namespaceId, req.name))
      return CommandResult(false, "", "Subscription '" ~ req.name ~ "' already exists");

    EventSubscription sub;
    sub.initEntity(req.tenantId, req.createdBy);

    sub.namespaceId = req.namespaceId;
    sub.environmentId = req.environmentId;
    sub.name = req.name;
    sub.description = req.description;
    sub.status = SubscriptionStatus.pending;
    sub.source = req.source;
    sub.eventTypes = req.eventTypes;
    sub.typeEncoding = req.typeEncoding.toTypeEncoding;
    sub.sinkUrl = req.sinkUrl;
    sub.sinkServiceName = req.sinkServiceName;
    sub.sinkServicePort = req.sinkServicePort;
    sub.maxInFlightMessages = req.maxInFlightMessages > 0 ? req.maxInFlightMessages : 10;
    sub.exactTypeMatching = req.exactTypeMatching;
    sub.filterAttributes = req.filterAttributes;
    sub.labels = req.labels;

    subscriptionRepository.save(sub);
    return CommandResult(true, sub.id.value, "");
  }

  CommandResult updateEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId, UpdateEventSubscriptionRequest request) {
    if (!subscriptionRepository.existsById(tenantId, subscriptionId))
      return CommandResult(false, "", "Subscription not found");

    auto sub = subscriptionRepository.findById(tenantId, subscriptionId);
    if (request.description.length > 0)
      sub.description = request.description;
    if (request.eventTypes.length > 0)
      sub.eventTypes = request.eventTypes;
    if (request.sinkUrl.length > 0)
      sub.sinkUrl = request.sinkUrl;
    if (request.sinkServiceName.length > 0)
      sub.sinkServiceName = request.sinkServiceName;
    if (request.sinkServicePort > 0)
      sub.sinkServicePort = request.sinkServicePort;
    if (request.maxInFlightMessages > 0)
      sub.maxInFlightMessages = request.maxInFlightMessages;
    sub.exactTypeMatching = request.exactTypeMatching;
    if (request.filterAttributes !is null)
      sub.filterAttributes = request.filterAttributes;
    if (request.labels !is null)
      sub.labels = request.labels;
    sub.updatedAt = clockSeconds();

    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.value, "");
  }

  CommandResult pauseEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
    auto sub = subscriptionRepository.findById(tenantId, subscriptionId);
    if (sub.isNull)
      return CommandResult(false, "", "Subscription not found");

    sub.status = SubscriptionStatus.paused;
    sub.updatedAt = clockSeconds();
    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.value, "");
  }

  CommandResult resumeEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
    auto sub = subscriptionRepository.findById(tenantId, subscriptionId);
    if (sub.isNull)
      return CommandResult(false, "", "Subscription not found");

    sub.status = SubscriptionStatus.active;
    sub.updatedAt = clockSeconds();
    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.value, "");
  }

  bool hasSubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
    return subscriptionRepository.existsById(tenantId, subscriptionId);
  }

  EventSubscription getSubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
    return subscriptionRepository.findById(tenantId, subscriptionId);
  }

  EventSubscription[] listByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return subscriptionRepository.findByNamespace(tenantId, namespaceId);
  }

  EventSubscription[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return subscriptionRepository.findByEnvironment(tenantId, environmentId);
  }

  CommandResult deleteSubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
    auto sub = subscriptionRepository.findById(tenantId, subscriptionId);
    if (sub.isNull)
      return CommandResult(false, "", "Subscription not found");

    subscriptionRepository.remove(sub);
    return CommandResult(true, sub.id.value, "");
  }
}
