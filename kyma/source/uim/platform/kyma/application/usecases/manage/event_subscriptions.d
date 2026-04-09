/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.event_subscriptions;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.event_subscription;
// import uim.platform.kyma.domain.ports.repositories.event_subscriptions;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for event subscription management.
class ManageEventSubscriptionsUseCase : UIMUseCase {
  private EventSubscriptionRepository subscriptionRepository;

  this(EventSubscriptionRepository subscriptionRepository) {
    this.subscriptionRepository = subscriptionRepository;
  }

  CommandResult create(CreateEventSubscriptionRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Subscription name is required");
    if (req.source.length == 0)
      return CommandResult(false, "", "Event source is required");
    if (req.eventTypes.length == 0)
      return CommandResult(false, "", "At least one event type is required");

    auto existing = subscriptionRepository.findByName(req.namespaceId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Subscription '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;
    auto id = randomUUID();

    EventSubscription sub;
    sub.id = randomUUID();
    sub.namespaceId = req.namespaceId;
    sub.environmentId = req.environmentId;
    sub.tenantId = req.tenantId;
    sub.name = req.name;
    sub.description = req.description;
    sub.status = SubscriptionStatus.pending;
    sub.source = req.source;
    sub.eventTypes = req.eventTypes;
    sub.typeEncoding = parseTypeEncoding(req.typeEncoding);
    sub.sinkUrl = req.sinkUrl;
    sub.sinkServiceName = req.sinkServiceName;
    sub.sinkServicePort = req.sinkServicePort;
    sub.maxInFlightMessages = req.maxInFlightMessages > 0 ? req.maxInFlightMessages : 10;
    sub.exactTypeMatching = req.exactTypeMatching;
    sub.filterAttributes = req.filterAttributes;
    sub.labels = req.labels;
    sub.createdBy = req.createdBy;
    sub.createdAt = clockSeconds();
    sub.modifiedAt = sub.createdAt;

    subscriptionRepository.save(sub);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateSubscription(EventSubscriptionId subscriptionId, UpdateEventSubscriptionRequest request) {
    if (!subscriptionRepository.existsById(subscriptionId))
      return CommandResult(false, "", "Subscription not found");
    
    auto sub = subscriptionRepository.findById(subscriptionId);
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
    sub.modifiedAt = clockSeconds();

    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.toString(), "");
  }

  CommandResult pauseSubscription(EventSubscriptionId subscriptionId) {
    if (!subscriptionRepository.existsById(subscriptionId))
      return CommandResult(false, "", "Subscription not found");
    
    auto sub = subscriptionRepository.findById(subscriptionId);
    sub.status = SubscriptionStatus.paused;
    sub.modifiedAt = clockSeconds();
    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.toString(), "");
  }

  CommandResult resumeSubscription(EventSubscriptionId subscriptionId) {
    if (!subscriptionRepository.existsById(subscriptionId))
      return CommandResult(false, "", "Subscription not found");
    
    auto sub = subscriptionRepository.findById(subscriptionId);
    sub.status = SubscriptionStatus.active;
    sub.modifiedAt = clockSeconds();
    subscriptionRepository.update(sub);
    return CommandResult(true, subscriptionId.toString(), "");
  }

  EventSubscription getSubscription(EventSubscriptionId subscriptionId) {
    return subscriptionRepository.findById(subscriptionId);
  }

  EventSubscription[] listByNamespace(NamespaceId namespaceId) {
    return subscriptionRepository.findByNamespace(namespaceId);
  }

  EventSubscription[] listByEnvironment(KymaEnvironmentId environmentId) {
    return subscriptionRepository.findByEnvironment(environmentId);
  }

  EventSubscription[] listBySource(string source) {
    return subscriptionRepository.findBySource(source);
  }

  CommandResult deleteSubscription(EventSubscriptionId subscriptionId) {
    if (!subscriptionRepository.existsById(subscriptionId))
      return CommandResult(false, "", "Subscription not found");

    subscriptionRepository.remove(subscriptionId);
    return CommandResult(true, subscriptionId.toString(), "");
  }

  private EventTypeEncoding parseTypeEncoding(string s) {
    switch (s) {
    case "exact":
      return EventTypeEncoding.exact;
    case "prefix":
      return EventTypeEncoding.prefix;
    default:
      return EventTypeEncoding.exact;
    }
  }
}


