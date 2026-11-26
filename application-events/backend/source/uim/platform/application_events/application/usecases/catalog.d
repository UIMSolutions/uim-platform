/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The event catalog (topics) and the delivery channels.
///
/// Rules: an event type is unique per tenant and cannot change; its owner
/// must be a producer. A channel belongs to a consumer system, its type and
/// consumer cannot change, a webhook needs an http(s) endpoint. Topics and
/// channels in use by subscriptions cannot be deleted.
module uim.platform.application_events.application.usecases.catalog;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class ManageTopicsUseCase : ResourceInteractor!(EventTopic, EventTopicId, TopicInput), IManageTopics {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(EventTopic, EventTopicId) store() {
    return repos.topics;
  }

  protected override string what() {
    return "Event type";
  }

  protected override string eventPrefix() {
    return "topic";
  }

  protected override string[] immutableAttributes() {
    return ["eventType"];
  }

  protected override TopicInput toInput(const EventTopic e) {
    return TopicInput(e.eventType, e.title, e.description, e.category, e.version_, e.ownerSystemId.value);
  }

  protected override void fromInput(TenantId t, ref EventTopic e, TopicInput i, bool creating) {
    e.eventType = i.eventType.strip;
    if (creating && !findByEventType(t, e.eventType).isNull)
      throw AehException.conflict("Event type '" ~ e.eventType ~ "' is already registered");
    e.title = i.title.strip;
    e.description = i.description.strip;
    e.category = i.category.strip;
    e.version_ = i.version_.strip.length ? i.version_.strip : "1.0.0";
    auto owner = optionalReference!SystemRegistrationId(repos.systems, t, i.ownerSystemId, "Owner system");
    e.ownerSystemId = SystemRegistrationId(owner);
    if (owner.length && !systemOf(t, e.ownerSystemId).produces)
      throw AehException.ruleViolation("The owner of an event type must be a producer system");
  }

  protected override void beforeRemove(TenantId t, const EventTopic e, UserId actor) {
    requireUnused("Event type '" ~ e.eventType ~ "'", repos.subscriptions.countByReference(t, "eventType", e.eventType),
      "subscriptions");
  }

  EventTopic findByEventType(TenantId t, string eventType) {
    auto found = repos.topics.findByReference(t, "eventType", eventType.strip);
    return found.length ? found[0] : EventTopic.init;
  }

  EventTopic setStatus(TenantId t, EventTopicId id, TopicStatus status, UserId actor) {
    auto topic = get(t, id);
    if (topic.status == status)
      throw AehException.ruleViolation("Event type '" ~ topic.eventType ~ "' is already " ~ cast(string) status);
    topic.status = status;
    return changed(topic, actor, "topic." ~ cast(string) status);
  }
}

class ManageChannelsUseCase : ResourceInteractor!(EventChannel, EventChannelId, ChannelInput), IManageChannels {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(EventChannel, EventChannelId) store() {
    return repos.channels;
  }

  protected override string what() {
    return "Channel";
  }

  protected override string eventPrefix() {
    return "channel";
  }

  protected override string[] immutableAttributes() {
    return ["channelType", "consumerSystemId"];
  }

  protected override ChannelInput toInput(const EventChannel e) {
    return ChannelInput(e.name, e.description, cast(string) e.channelType, e.endpoint, e.consumerSystemId.value,
      cast(string) e.deliveryMode, e.maxSizeBytes);
  }

  protected override void fromInput(TenantId t, ref EventChannel e, ChannelInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.channelType = parseDomainEnumOr!ChannelType(i.channelType, ChannelType.webhook, "channel type");
    e.endpoint = e.channelType == ChannelType.queue ? "" : i.endpoint.strip;
    e.deliveryMode = parseDomainEnumOr!DeliveryMode(i.deliveryMode, DeliveryMode.atLeastOnce, "delivery mode");
    e.maxSizeBytes = i.maxSizeBytes;
    e.consumerSystemId = SystemRegistrationId(i.consumerSystemId.strip);
    if (creating) {
      auto consumer = systemOf(t, e.consumerSystemId, "Consumer system");
      if (!consumer.consumes)
        throw AehException.ruleViolation("System '" ~ consumer.name ~ "' does not consume events (type "
            ~ cast(string) consumer.systemType ~ ")");
    }
  }

  protected override void beforeRemove(TenantId t, const EventChannel e, UserId actor) {
    requireUnused("Channel '" ~ e.name ~ "'", repos.subscriptions.countByReference(t, "channelId", e.id.value), "subscriptions");
    auto open = repos.messages.findByReference(t, "channelId", e.id.value).count!(m => m.isOpen);
    requireUnused("Channel '" ~ e.name ~ "'", open, "undelivered messages");
  }

  EventChannel setStatus(TenantId t, EventChannelId id, ChannelStatus status, UserId actor) {
    auto c = get(t, id);
    if (c.status == status)
      throw AehException.ruleViolation("Channel '" ~ c.name ~ "' is already " ~ cast(string) status);
    c.status = status;
    return changed(c, actor, "channel." ~ cast(string) status);
  }
}
