/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.consume_messages;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Reading and consuming (auto-acknowledge) queue messages.
class ConsumeMessagesUseCase : IConsumeMessages {
  protected IQueueMessageRepository messages;
  protected IQueueRepository queues;
  protected IMessageClientRepository clients;
  protected IMessageBindingRepository bindings;

  this(IQueueMessageRepository messages, IQueueRepository queues, IMessageClientRepository clients,
    IMessageBindingRepository bindings) {
    this.messages = messages;
    this.queues = queues;
    this.clients = clients;
    this.bindings = bindings;
  }

  QueueMessage[] listMessages(TenantId tenantId, QueueId queueId) {
    queues.findById(tenantId, queueId).required("Queue '" ~ queueId.value ~ "'");
    auto now = nowStdTime();
    return messages.findByQueue(tenantId, queueId).filter!(m => !m.isExpired(now)).array;
  }

  QueueMessage[] listAllMessages(TenantId tenantId) {
    auto now = nowStdTime();
    return messages.findAll(tenantId).filter!(m => !m.isExpired(now)).array;
  }

  QueueMessage getMessage(TenantId tenantId, QueueMessageId id) {
    return messages.findById(tenantId, id).required("Message '" ~ id.value ~ "'");
  }

  QueueMessage[] consume(ConsumeMessagesRequest r) {
    auto q = queues.findById(r.tenantId, r.queueId).required("Queue '" ~ r.queueId.value ~ "'");
    if (!q.deliversMessages)
      throw EventsException.ruleViolation("Queue '" ~ q.name ~ "' does not deliver messages (egress disabled or not active)");
    if (r.maxMessages < 1 || r.maxMessages > 1000)
      throw EventsException.invalid("maxMessages must be between 1 and 1000");
    if (r.clientId.strip.length > 0)
      authorize(r.tenantId, MessageClientId(r.clientId.strip), q);

    auto now = nowStdTime();
    QueueMessage[] taken;
    foreach (m; messages.findByQueue(r.tenantId, q.id)) {
      if (m.isExpired(now)) {
        messages.removeById(r.tenantId, m.id);
        continue;
      }
      if (taken.length >= cast(size_t) r.maxMessages)
        break;
      messages.removeById(r.tenantId, m.id);
      taken ~= m;
    }
    return taken;
  }

  void acknowledge(TenantId tenantId, QueueMessageId id) {
    getMessage(tenantId, id);
    messages.removeById(tenantId, id);
  }

  size_t purge(TenantId tenantId, QueueId queueId) {
    queues.findById(tenantId, queueId).required("Queue '" ~ queueId.value ~ "'");
    return messages.removeByQueue(tenantId, queueId);
  }

  size_t removeExpired(TenantId tenantId) {
    auto now = nowStdTime();
    size_t removed;
    foreach (m; messages.findAll(tenantId))
      if (m.isExpired(now) && messages.removeById(tenantId, m.id))
        removed++;
    return removed;
  }

  protected void authorize(TenantId t, MessageClientId clientId, const EventQueue q) {
    auto client = clients.findById(t, clientId).required("Message client '" ~ clientId.value ~ "'");
    if (!client.isActive)
      throw EventsException.ruleViolation("Message client '" ~ client.name ~ "' is " ~ cast(string) client.status);
    foreach (b; bindings.findByClient(t, client.id))
      if (b.isActive && b.queueId == q.id && allowsSubscribe(b.permission))
        return;
    throw EventsException.ruleViolation("Client '" ~ client.name ~ "' has no subscribe binding for queue '" ~ q.name ~ "'");
  }
}
