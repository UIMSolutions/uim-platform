/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST controller, the CLI and the GUI.
module uim.platform.events.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.events;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates EventsException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

private size_t[string] countBy(T)(T[] items, scope string delegate(const T) @safe keyOf) {
  size_t[string] counts;
  foreach (item; items)
    counts[keyOf(item)]++;
  return counts;
}

ODataEngine eventsEngine(EventsPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(eventsModel());

  // ── Messaging services ────────────────────────────────────────────────────
  auto services = new DelegateEntitySetProvider;
  services.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto clients = countBy(ports.clients.listMessageClients(t), (const MessageClient e) => e.serviceId.value);
    auto queues = countBy(ports.queues.listQueues(t), (const EventQueue e) => e.serviceId.value);
    auto channels = countBy(ports.channels.listEventChannels(t), (const EventChannel e) => e.serviceId.value);
    Json[] rows;
    foreach (e; ports.services.listMessagingServices(t))
      rows ~= messagingServiceRow(e, clients.get(e.id.value, 0), queues.get(e.id.value, 0), channels.get(e.id.value, 0));
    return rows;
  };
  services.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.services.getMessagingService(t, MessagingServiceId(key));
    return messagingServiceRow(e, ports.clients.listMessageClients(t).count!(c => c.serviceId == e.id),
      ports.queues.listQueues(t).count!(q => q.serviceId == e.id), ports.channels.listEventChannels(t).count!(c => c.serviceId == e.id));
  };
  services.onCreate = (const RequestContext ctx, Json p) => messagingServiceRow(
    ports.services.createMessagingService(createMessagingServiceRequest(ctx, p)));
  services.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.services.updateMessagingService(updateMessagingServiceRequest(ctx, key, p));
    return services.onGet(ctx, key);
  };
  services.onRemove = (const RequestContext ctx, string key) {
    ports.services.deleteMessagingService(tenantOf(ctx), MessagingServiceId(key));
  };

  // ── Message clients ───────────────────────────────────────────────────────
  auto clients = new DelegateEntitySetProvider;
  clients.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto bound = countBy(ports.bindings.listMessageBindings(t), (const MessageBinding b) => b.clientId.value);
    Json[] rows;
    foreach (e; ports.clients.listMessageClients(t))
      rows ~= messageClientRow(e, bound.get(e.id.value, 0));
    return rows;
  };
  clients.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.clients.getMessageClient(t, MessageClientId(key));
    return messageClientRow(e, ports.bindings.listMessageBindings(t).count!(b => b.clientId == e.id));
  };
  clients.onCreate = (const RequestContext ctx, Json p) => messageClientRow(
    ports.clients.createMessageClient(createMessageClientRequest(ctx, p)));
  clients.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.clients.updateMessageClient(updateMessageClientRequest(ctx, key, p));
    return clients.onGet(ctx, key);
  };
  clients.onRemove = (const RequestContext ctx, string key) {
    ports.clients.deleteMessageClient(tenantOf(ctx), MessageClientId(key));
  };

  // ── Queues ────────────────────────────────────────────────────────────────
  Json queueOf(const RequestContext ctx, const EventQueue e, size_t[string] messages, size_t[string] subscriptions,
    size_t[string] webhooks) {
    return queueRow(e, messages.get(e.id.value, 0), subscriptions.get(e.id.value, 0), webhooks.get(e.id.value, 0));
  }

  auto queues = new DelegateEntitySetProvider;
  queues.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto messages = countBy(ports.consumer.listAllMessages(t), (const QueueMessage m) => m.queueId.value);
    auto subscriptions = countBy(ports.subscriptions.listQueueSubscriptions(t), (const QueueSubscription s) => s.queueId.value);
    auto webhooks = countBy(ports.webhooks.listWebhooks(t), (const Webhook w) => w.queueId.value);
    Json[] rows;
    foreach (e; ports.queues.listQueues(t))
      rows ~= queueOf(ctx, e, messages, subscriptions, webhooks);
    return rows;
  };
  queues.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.queues.getQueue(t, QueueId(key));
    return queueRow(e, ports.consumer.listMessages(t, e.id).length,
      ports.subscriptions.listQueueSubscriptions(t).count!(s => s.queueId == e.id),
      ports.webhooks.listWebhooks(t).count!(w => w.queueId == e.id));
  };
  queues.onCreate = (const RequestContext ctx, Json p) => queueRow(ports.queues.createQueue(createQueueRequest(ctx, p)));
  queues.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.queues.updateQueue(updateQueueRequest(ctx, key, p));
    return queues.onGet(ctx, key);
  };
  queues.onRemove = (const RequestContext ctx, string key) {
    ports.queues.deleteQueue(tenantOf(ctx), QueueId(key));
  };

  // ── Queue subscriptions ───────────────────────────────────────────────────
  auto subscriptions = new DelegateEntitySetProvider;
  subscriptions.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.subscriptions.listQueueSubscriptions(tenantOf(ctx)))
      rows ~= queueSubscriptionRow(e);
    return rows;
  };
  subscriptions.onGet = (const RequestContext ctx, string key) => queueSubscriptionRow(
    ports.subscriptions.getQueueSubscription(tenantOf(ctx), QueueSubscriptionId(key)));
  subscriptions.onCreate = (const RequestContext ctx, Json p) => queueSubscriptionRow(
    ports.subscriptions.createQueueSubscription(createQueueSubscriptionRequest(ctx, p)));
  subscriptions.onUpdate = (const RequestContext ctx, string key, Json p) => queueSubscriptionRow(
    ports.subscriptions.updateQueueSubscription(updateQueueSubscriptionRequest(ctx, key, p)));
  subscriptions.onRemove = (const RequestContext ctx, string key) {
    ports.subscriptions.deleteQueueSubscription(tenantOf(ctx), QueueSubscriptionId(key));
  };

  // ── Webhooks ──────────────────────────────────────────────────────────────
  auto webhooks = new DelegateEntitySetProvider;
  webhooks.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.webhooks.listWebhooks(tenantOf(ctx)))
      rows ~= webhookRow(e);
    return rows;
  };
  webhooks.onGet = (const RequestContext ctx, string key) => webhookRow(ports.webhooks.getWebhook(tenantOf(ctx), WebhookId(key)));
  webhooks.onCreate = (const RequestContext ctx, Json p) => webhookRow(ports.webhooks.createWebhook(createWebhookRequest(ctx, p)));
  webhooks.onUpdate = (const RequestContext ctx, string key, Json p) => webhookRow(
    ports.webhooks.updateWebhook(updateWebhookRequest(ctx, key, p)));
  webhooks.onRemove = (const RequestContext ctx, string key) {
    ports.webhooks.deleteWebhook(tenantOf(ctx), WebhookId(key));
  };

  // ── Event channels ────────────────────────────────────────────────────────
  auto channels = new DelegateEntitySetProvider;
  channels.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto bound = countBy(ports.bindings.listMessageBindings(t), (const MessageBinding b) => b.channelId.value);
    Json[] rows;
    foreach (e; ports.channels.listEventChannels(t))
      rows ~= eventChannelRow(e, bound.get(e.id.value, 0));
    return rows;
  };
  channels.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.channels.getEventChannel(t, EventChannelId(key));
    return eventChannelRow(e, ports.bindings.listMessageBindings(t).count!(b => b.channelId == e.id));
  };
  channels.onCreate = (const RequestContext ctx, Json p) => eventChannelRow(
    ports.channels.createEventChannel(createEventChannelRequest(ctx, p)));
  channels.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.channels.updateEventChannel(updateEventChannelRequest(ctx, key, p));
    return channels.onGet(ctx, key);
  };
  channels.onRemove = (const RequestContext ctx, string key) {
    ports.channels.deleteEventChannel(tenantOf(ctx), EventChannelId(key));
  };

  // ── Message bindings ──────────────────────────────────────────────────────
  auto bindings = new DelegateEntitySetProvider;
  bindings.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.bindings.listMessageBindings(tenantOf(ctx)))
      rows ~= messageBindingRow(e);
    return rows;
  };
  bindings.onGet = (const RequestContext ctx, string key) => messageBindingRow(
    ports.bindings.getMessageBinding(tenantOf(ctx), MessageBindingId(key)));
  bindings.onCreate = (const RequestContext ctx, Json p) => messageBindingRow(
    ports.bindings.createMessageBinding(createMessageBindingRequest(ctx, p)));
  bindings.onUpdate = (const RequestContext ctx, string key, Json p) => messageBindingRow(
    ports.bindings.updateMessageBinding(updateMessageBindingRequest(ctx, key, p)));
  bindings.onRemove = (const RequestContext ctx, string key) {
    ports.bindings.deleteMessageBinding(tenantOf(ctx), MessageBindingId(key));
  };

  // ── Queue messages (read, delete = acknowledge) ───────────────────────────
  auto messages = new DelegateEntitySetProvider;
  messages.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.consumer.listAllMessages(tenantOf(ctx)))
      rows ~= queueMessageRow(e);
    return rows;
  };
  messages.onGet = (const RequestContext ctx, string key) => queueMessageRow(
    ports.consumer.getMessage(tenantOf(ctx), QueueMessageId(key)));
  messages.onRemove = (const RequestContext ctx, string key) {
    ports.consumer.acknowledge(tenantOf(ctx), QueueMessageId(key));
  };

  // ── Statistics (singleton) ────────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("MessagingServices", new PortProvider(services))
    .provide("MessageClients", new PortProvider(clients))
    .provide("Queues", new PortProvider(queues))
    .provide("QueueSubscriptions", new PortProvider(subscriptions))
    .provide("Webhooks", new PortProvider(webhooks))
    .provide("EventChannels", new PortProvider(channels))
    .provide("MessageBindings", new PortProvider(bindings))
    .provide("QueueMessages", new PortProvider(messages))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ───────────────────────────────────────────────────────────────
  engine.handle("PublishEvent", (const RequestContext ctx, Json p) => translated!Json(
      () => publishResultRow(ports.publisher.publish(publishEventRequest(ctx, p)))));
  engine.handle("ConsumeMessages", (const RequestContext ctx, Json p) => translated!Json(() {
      auto rows = Json.emptyArray;
      foreach (m; ports.consumer.consume(consumeMessagesRequest(ctx, p)))
        rows ~= queueMessageRow(m);
      return rows;
    }));
  engine.handle("PurgeQueue", (const RequestContext ctx, Json p) => translated!Json(() => purgeResultRow(textOf(p, "queueId"),
      ports.consumer.purge(tenantOf(ctx), QueueId(textOf(p, "queueId"))))));
  engine.handle("DeliverWebhook", (const RequestContext ctx, Json p) => translated!Json(() => deliveryResultRow(
      ports.delivery.deliver(tenantOf(ctx), WebhookId(textOf(p, "webhookId")), actorOf(ctx)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
