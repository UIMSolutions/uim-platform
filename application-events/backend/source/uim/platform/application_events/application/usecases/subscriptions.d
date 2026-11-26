/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Subscriptions and their filters.
///
/// Rules: the producer must produce and the consumer consume events; the
/// channel must belong to the consumer; both systems belong to the same
/// formation (or both to none); producer and consumer cannot change. An
/// exact event type must be registered (requireRegisteredTopics) and may
/// not be deprecated or retired for a new subscription. A subscription is
/// unique per producer, consumer, event type and channel. Deleting a
/// subscription deletes its filters; its messages stay in the history.
module uim.platform.application_events.application.usecases.subscriptions;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class ManageSubscriptionsUseCase : ResourceInteractor!(EventSubscription, EventSubscriptionId, SubscriptionInput),
IManageSubscriptions {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(EventSubscription, EventSubscriptionId) store() {
    return repos.subscriptions;
  }

  protected override string what() {
    return "Subscription";
  }

  protected override string eventPrefix() {
    return "subscription";
  }

  protected override string[] immutableAttributes() {
    return ["producerSystemId", "consumerSystemId"];
  }

  protected override SubscriptionInput toInput(const EventSubscription e) {
    return SubscriptionInput(e.name, e.description, e.producerSystemId.value, e.consumerSystemId.value, e.eventType,
      e.channelId.value, e.maxRetries, e.retryBackoffSeconds);
  }

  protected override void fromInput(TenantId t, ref EventSubscription e, SubscriptionInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.producerSystemId = SystemRegistrationId(i.producerSystemId.strip);
    e.consumerSystemId = SystemRegistrationId(i.consumerSystemId.strip);
    auto previousType = e.eventType;
    e.eventType = i.eventType.strip;
    e.channelId = EventChannelId(i.channelId.strip);
    e.maxRetries = i.maxRetries;
    e.retryBackoffSeconds = i.retryBackoffSeconds;

    auto producer = systemOf(t, e.producerSystemId, "Producer system");
    auto consumer = systemOf(t, e.consumerSystemId, "Consumer system");
    if (!producer.produces)
      throw AehException.ruleViolation("System '" ~ producer.name ~ "' does not produce events");
    if (!consumer.consumes)
      throw AehException.ruleViolation("System '" ~ consumer.name ~ "' does not consume events");
    if (producer.formationId != consumer.formationId)
      throw AehException.ruleViolation("Producer '" ~ producer.name ~ "' and consumer '" ~ consumer.name
          ~ "' must belong to the same formation");
    e.formationId = producer.formationId;

    auto channel = channelOf(t, e.channelId);
    if (channel.consumerSystemId != e.consumerSystemId)
      throw AehException.ruleViolation("Channel '" ~ channel.name ~ "' belongs to another consumer system");

    requireEventTypePattern(e.eventType);
    if (policy.requireRegisteredTopics && !hasWildcard(e.eventType) && (creating || e.eventType != previousType)) {
      auto found = repos.topics.findByReference(t, "eventType", e.eventType);
      if (found.length == 0)
        throw AehException.ruleViolation("Event type '" ~ e.eventType ~ "' is not registered in the catalog");
      if (found[0].status != TopicStatus.active)
        throw AehException.ruleViolation("Event type '" ~ e.eventType ~ "' is " ~ cast(string) found[0].status
            ~ " — new subscriptions are not allowed");
    }
  }

  protected override void beforeSave(TenantId t, ref EventSubscription e, bool creating) {
    foreach (other; repos.subscriptions.findByReference(t, "producerSystemId", e.producerSystemId.value))
      if (other.id != e.id && other.consumerSystemId == e.consumerSystemId && other.eventType == e.eventType
        && other.channelId == e.channelId)
        throw AehException.conflict("Subscription '" ~ other.id.value ~ "' already routes '" ~ e.eventType
            ~ "' to channel '" ~ e.channelId.value ~ "'");
  }

  protected override void beforeRemove(TenantId t, const EventSubscription e, UserId actor) {
    repos.filters.removeByReference(t, "subscriptionId", e.id.value);
  }

  EventSubscription pause(TenantId t, EventSubscriptionId id, UserId actor) {
    auto s = get(t, id);
    if (!s.isActive)
      throw AehException.ruleViolation("Subscription '" ~ s.name ~ "' is already paused");
    s.status = SubscriptionStatus.paused;
    return changed(s, actor, "subscription.paused");
  }

  EventSubscription resume(TenantId t, EventSubscriptionId id, UserId actor) {
    auto s = get(t, id);
    if (s.isActive)
      throw AehException.ruleViolation("Subscription '" ~ s.name ~ "' is not paused");
    s.status = SubscriptionStatus.active;
    return changed(s, actor, "subscription.resumed");
  }
}

class ManageFiltersUseCase : ResourceInteractor!(EventFilter, EventFilterId, FilterInput), IManageFilters {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(EventFilter, EventFilterId) store() {
    return repos.filters;
  }

  protected override string what() {
    return "Filter";
  }

  protected override string eventPrefix() {
    return "filter";
  }

  protected override string[] immutableAttributes() {
    return ["subscriptionId"];
  }

  protected override FilterInput toInput(const EventFilter e) {
    return FilterInput(e.subscriptionId.value, cast(string) e.filterType, e.attribute, cast(string) e.operator_, e.value,
      e.active, e.description);
  }

  protected override void fromInput(TenantId t, ref EventFilter e, FilterInput i, bool creating) {
    e.subscriptionId = EventSubscriptionId(i.subscriptionId.strip);
    if (creating)
      subscriptionOf(t, e.subscriptionId);
    e.filterType = parseDomainEnumOr!FilterType(i.filterType, FilterType.include, "filter type");
    e.attribute = i.attribute.strip;
    e.operator_ = parseDomainEnumOr!EventFilterOperator(i.operator_, EventFilterOperator.equals, "operator");
    e.value = e.operator_ == EventFilterOperator.exists ? "" : i.value.strip;
    e.active = i.active;
    e.description = i.description.strip;
  }

  EventFilter[] listOf(TenantId t, EventSubscriptionId subscription) {
    subscriptionOf(t, subscription);
    return repos.filters.findByReference(t, "subscriptionId", subscription.value);
  }
}
