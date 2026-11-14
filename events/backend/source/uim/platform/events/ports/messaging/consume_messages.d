/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port: read, consume (auto-acknowledge) and purge queue messages.
module uim.platform.events.ports.messaging.consume_messages;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IConsumeMessages {
  /// Messages of a queue (oldest first), expired ones excluded.
  QueueMessage[] listMessages(TenantId tenantId, QueueId queueId);
  /// All messages of the tenant (all queues).
  QueueMessage[] listAllMessages(TenantId tenantId);
  QueueMessage getMessage(TenantId tenantId, QueueMessageId id);
  /// Remove and return up to maxMessages messages (FIFO).
  QueueMessage[] consume(ConsumeMessagesRequest request);
  /// Acknowledge (remove) one message.
  void acknowledge(TenantId tenantId, QueueMessageId id);
  /// Remove all messages of a queue; returns the count.
  size_t purge(TenantId tenantId, QueueId queueId);
  /// Remove expired messages of the tenant; returns the count.
  size_t removeExpired(TenantId tenantId);
}
