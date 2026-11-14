/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.publish_events;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Topic based publishing: validate the event against the service
/// (status, namespace, quotas) and the publishing client (status, permitted
/// namespace, publish binding), then store one copy per matching queue.
class PublishEventsUseCase : IPublishEvents {
  protected IMessagingServiceRepository services;
  protected IMessageClientRepository clients;
  protected IMessageBindingRepository bindings;
  protected IEventChannelRepository channels;
  protected IQueueSubscriptionRepository subscriptions;
  protected IQueueRepository queues;
  protected IQueueMessageRepository messages;

  this(IMessagingServiceRepository services, IMessageClientRepository clients, IMessageBindingRepository bindings,
    IEventChannelRepository channels, IQueueSubscriptionRepository subscriptions, IQueueRepository queues,
    IQueueMessageRepository messages) {
    this.services = services;
    this.clients = clients;
    this.bindings = bindings;
    this.channels = channels;
    this.subscriptions = subscriptions;
    this.queues = queues;
    this.messages = messages;
  }

  PublishResult publish(PublishEventRequest r) {
    auto t = r.tenantId;
    auto topic = r.topic.strip.strip("/");
    MessageClient client;
    if (r.clientId.strip.length > 0) {
      client = clients.findById(t, MessageClientId(r.clientId.strip)).required("Message client '" ~ r.clientId ~ "'");
      if (!client.isActive)
        throw EventsException.ruleViolation("Message client '" ~ client.name ~ "' is " ~ cast(string) client.status);
    }
    auto serviceId = r.serviceId.strip.length > 0 ? MessagingServiceId(r.serviceId.strip) : client.serviceId;
    if (serviceId.isNull)
      throw EventsException.invalid("serviceId or clientId is required");
    if (!client.isNull && client.serviceId != serviceId)
      throw EventsException.invalid("The client belongs to another messaging service");
    auto service = services.findById(t, serviceId).required("Messaging service '" ~ serviceId.value ~ "'");
    if (!service.isActive)
      throw EventsException.ruleViolation("Messaging service '" ~ service.name ~ "' is " ~ cast(string) service.status);

    if (!isValidTopic(topic))
      throw EventsException.invalid("Invalid topic '" ~ r.topic ~ "'");
    if (!isInNamespace(topic, service.namespace))
      throw EventsException.invalid("Topic '" ~ topic ~ "' is outside namespace '" ~ service.namespace ~ "'");
    auto channel = channels.findByTopic(t, service.id, topic);
    if (!channel.isNull && channel.status == EventChannelStatus.inactive)
      throw EventsException.ruleViolation("Event channel '" ~ channel.name ~ "' is inactive");
    if (!client.isNull)
      authorize(client, topic, channel);

    auto quota = quotaOf(service);
    if (r.payload.length > quota.maxMessageSize)
      throw EventsException.quotaExceeded(format("Message of %d bytes exceeds the limit of %d bytes", r.payload.length,
          quota.maxMessageSize));

    PublishResult result;
    result.messageId = newResourceId();
    result.topic = topic;
    auto now = nowStdTime();
    foreach (queueId; routeTopic(subscriptions.findByService(t, service.id), topic)) {
      auto q = queues.findById(t, queueId);
      if (q.isNull)
        continue;
      if (!q.acceptsMessages || r.payload.length > effectiveMessageSize(q, service)
        || messages.countByQueue(t, q.id) >= effectiveDepth(q, service)) {
        result.rejectedQueueIds ~= q.id.value;
        continue;
      }
      QueueMessage m;
      stampCreated!(QueueMessage, QueueMessageId)(m, t, r.actor, "");
      m.createdAt = now;
      m.updatedAt = now;
      m.queueId = q.id;
      m.serviceId = service.id;
      m.correlationId = result.messageId;
      m.topic = topic;
      m.payload = r.payload;
      m.contentType = r.contentType.length > 0 ? r.contentType : "application/json";
      m.expiresAt = expiryAfter(now, q.messageTtlSeconds);
      m.publisherId = client.id;
      messages.save(m);
      result.queueIds ~= q.id.value;
    }
    return result;
  }

  /// The client needs its namespace to cover the topic and an active
  /// publish binding: a channel binding of that topic, or any queue binding.
  protected void authorize(const MessageClient client, string topic, const EventChannel channel) {
    if (client.permittedNamespace.length > 0 && !isInNamespace(topic, client.permittedNamespace))
      throw EventsException.ruleViolation("Client '" ~ client.name ~ "' may only publish below '" ~ client.permittedNamespace ~ "'");
    foreach (b; bindings.findByClient(client.tenantId, client.id))
      if (b.isActive && allowsPublish(b.permission) && (!b.queueId.isNull || (!channel.isNull && b.channelId == channel.id)))
        return;
    throw EventsException.ruleViolation("Client '" ~ client.name ~ "' has no publish binding for '" ~ topic ~ "'");
  }
}
