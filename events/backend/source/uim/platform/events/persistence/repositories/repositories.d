/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.events.persistence.repositories.repositories;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessagingServiceRepository : DocumentRepository!(MessagingService, MessagingServiceId, messagingServiceToRecord,
  recordToMessagingService), IMessagingServiceRepository {
  this(IDocumentStore store) {
    super(store, Collections.messagingServices);
  }

  MessagingService findByName(TenantId t, string name) {
    return first(t, (const MessagingService e) => e.name == name);
  }

  MessagingService findByNamespace(TenantId t, string namespace) {
    return first(t, (const MessagingService e) => e.namespace == namespace);
  }
}

class MessageClientRepository : DocumentRepository!(MessageClient, MessageClientId, messageClientToRecord,
  recordToMessageClient), IMessageClientRepository {
  this(IDocumentStore store) {
    super(store, Collections.messageClients);
  }

  MessageClient[] findByService(TenantId t, MessagingServiceId serviceId) {
    return where(t, (const MessageClient e) => e.serviceId == serviceId);
  }

  MessageClient findByName(TenantId t, MessagingServiceId serviceId, string name) {
    return first(t, (const MessageClient e) => e.serviceId == serviceId && e.name == name);
  }
}

class QueueRepository : DocumentRepository!(EventQueue, QueueId, queueToRecord, recordToEventQueue), IQueueRepository {
  this(IDocumentStore store) {
    super(store, Collections.queues);
  }

  EventQueue[] findByService(TenantId t, MessagingServiceId serviceId) {
    return where(t, (const EventQueue e) => e.serviceId == serviceId);
  }

  EventQueue findByName(TenantId t, MessagingServiceId serviceId, string name) {
    return first(t, (const EventQueue e) => e.serviceId == serviceId && e.name == name);
  }

  EventQueue[] findByDeadLetterQueue(TenantId t, QueueId dlq) {
    return where(t, (const EventQueue e) => e.deadLetterQueueId == dlq);
  }
}

class QueueSubscriptionRepository : DocumentRepository!(QueueSubscription, QueueSubscriptionId, queueSubscriptionToRecord,
  recordToQueueSubscription), IQueueSubscriptionRepository {
  this(IDocumentStore store) {
    super(store, Collections.queueSubscriptions);
  }

  QueueSubscription[] findByQueue(TenantId t, QueueId queueId) {
    return where(t, (const QueueSubscription e) => e.queueId == queueId);
  }

  QueueSubscription[] findByService(TenantId t, MessagingServiceId serviceId) {
    return where(t, (const QueueSubscription e) => e.serviceId == serviceId);
  }
}

class WebhookRepository : DocumentRepository!(Webhook, WebhookId, webhookToRecord, recordToWebhook), IWebhookRepository {
  this(IDocumentStore store) {
    super(store, Collections.webhooks);
  }

  Webhook[] findByQueue(TenantId t, QueueId queueId) {
    return where(t, (const Webhook e) => e.queueId == queueId);
  }

  Webhook[] findByService(TenantId t, MessagingServiceId serviceId) {
    return where(t, (const Webhook e) => e.serviceId == serviceId);
  }
}

class EventChannelRepository : DocumentRepository!(EventChannel, EventChannelId, eventChannelToRecord,
  recordToEventChannel), IEventChannelRepository {
  this(IDocumentStore store) {
    super(store, Collections.eventChannels);
  }

  EventChannel[] findByService(TenantId t, MessagingServiceId serviceId) {
    return where(t, (const EventChannel e) => e.serviceId == serviceId);
  }

  EventChannel findByTopic(TenantId t, MessagingServiceId serviceId, string topicName) {
    return first(t, (const EventChannel e) => e.serviceId == serviceId && e.topicName == topicName);
  }
}

class MessageBindingRepository : DocumentRepository!(MessageBinding, MessageBindingId, messageBindingToRecord,
  recordToMessageBinding), IMessageBindingRepository {
  this(IDocumentStore store) {
    super(store, Collections.messageBindings);
  }

  MessageBinding[] findByClient(TenantId t, MessageClientId clientId) {
    return where(t, (const MessageBinding e) => e.clientId == clientId);
  }

  MessageBinding[] findByQueue(TenantId t, QueueId queueId) {
    return where(t, (const MessageBinding e) => e.queueId == queueId);
  }

  MessageBinding[] findByChannel(TenantId t, EventChannelId channelId) {
    return where(t, (const MessageBinding e) => e.channelId == channelId);
  }
}

class QueueMessageRepository : DocumentRepository!(QueueMessage, QueueMessageId, queueMessageToRecord,
  recordToQueueMessage), IQueueMessageRepository {
  this(IDocumentStore store) {
    super(store, Collections.queueMessages);
  }

  QueueMessage[] findByQueue(TenantId t, QueueId queueId) {
    return where(t, (const QueueMessage e) => e.queueId == queueId);
  }

  size_t countByQueue(TenantId t, QueueId queueId) {
    size_t n;
    foreach (doc; store.all(collection, t.value))
      if (textField(doc, "queueId") == queueId.value)
        n++;
    return n;
  }

  size_t removeByQueue(TenantId t, QueueId queueId) {
    size_t n;
    foreach (doc; store.all(collection, t.value))
      if (textField(doc, "queueId") == queueId.value && store.remove(collection, t.value, textField(doc, "id")))
        n++;
    return n;
  }
}

///
unittest {
  auto store = new MemoryDocumentStore;
  auto repo = new QueueMessageRepository(store);
  auto t = TenantId("t");
  foreach (i; 0 .. 3) {
    QueueMessage m;
    m.tenantId = t;
    m.id = QueueMessageId("m" ~ i.to!string);
    m.createdAt = 10 - i; // newest first in insertion order
    m.queueId = QueueId(i < 2 ? "a" : "b");
    repo.save(m);
  }
  assert(repo.countByQueue(t, QueueId("a")) == 2);
  assert(repo.findByQueue(t, QueueId("a")).map!(m => m.id.value).array == ["m1", "m0"]); // oldest first
  assert(repo.removeByQueue(t, QueueId("a")) == 2 && repo.countAll(t) == 1);
}
