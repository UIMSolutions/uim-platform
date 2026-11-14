/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.events.ports.repositories.repositories;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IMessagingServiceRepository : IEntityRepository!(MessagingService, MessagingServiceId) {
  MessagingService findByName(TenantId t, string name);
  MessagingService findByNamespace(TenantId t, string namespace);
}

interface IMessageClientRepository : IEntityRepository!(MessageClient, MessageClientId) {
  MessageClient[] findByService(TenantId t, MessagingServiceId serviceId);
  MessageClient findByName(TenantId t, MessagingServiceId serviceId, string name);
}

interface IQueueRepository : IEntityRepository!(EventQueue, QueueId) {
  EventQueue[] findByService(TenantId t, MessagingServiceId serviceId);
  EventQueue findByName(TenantId t, MessagingServiceId serviceId, string name);
  /// Queues that use the queue as dead letter queue.
  EventQueue[] findByDeadLetterQueue(TenantId t, QueueId dlq);
}

interface IQueueSubscriptionRepository : IEntityRepository!(QueueSubscription, QueueSubscriptionId) {
  QueueSubscription[] findByQueue(TenantId t, QueueId queueId);
  QueueSubscription[] findByService(TenantId t, MessagingServiceId serviceId);
}

interface IWebhookRepository : IEntityRepository!(Webhook, WebhookId) {
  Webhook[] findByQueue(TenantId t, QueueId queueId);
  Webhook[] findByService(TenantId t, MessagingServiceId serviceId);
}

interface IEventChannelRepository : IEntityRepository!(EventChannel, EventChannelId) {
  EventChannel[] findByService(TenantId t, MessagingServiceId serviceId);
  EventChannel findByTopic(TenantId t, MessagingServiceId serviceId, string topicName);
}

interface IMessageBindingRepository : IEntityRepository!(MessageBinding, MessageBindingId) {
  MessageBinding[] findByClient(TenantId t, MessageClientId clientId);
  MessageBinding[] findByQueue(TenantId t, QueueId queueId);
  MessageBinding[] findByChannel(TenantId t, EventChannelId channelId);
}

interface IQueueMessageRepository : IEntityRepository!(QueueMessage, QueueMessageId) {
  /// Messages of a queue, oldest first.
  QueueMessage[] findByQueue(TenantId t, QueueId queueId);
  size_t countByQueue(TenantId t, QueueId queueId);
  size_t removeByQueue(TenantId t, QueueId queueId);
}
