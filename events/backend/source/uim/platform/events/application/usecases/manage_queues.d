/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_queues;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageQueuesUseCase : IManageQueues {
  protected IQueueRepository queues;
  protected IMessagingServiceRepository services;
  protected IQueueSubscriptionRepository subscriptions;
  protected IWebhookRepository webhooks;
  protected IMessageBindingRepository bindings;
  protected IQueueMessageRepository messages;

  this(IQueueRepository queues, IMessagingServiceRepository services, IQueueSubscriptionRepository subscriptions,
    IWebhookRepository webhooks, IMessageBindingRepository bindings, IQueueMessageRepository messages) {
    this.queues = queues;
    this.services = services;
    this.subscriptions = subscriptions;
    this.webhooks = webhooks;
    this.bindings = bindings;
    this.messages = messages;
  }

  EventQueue[] listQueues(TenantId tenantId) {
    return queues.findAll(tenantId);
  }

  EventQueue getQueue(TenantId tenantId, QueueId id) {
    return queues.findById(tenantId, id).required("Queue '" ~ id.value ~ "'");
  }

  EventQueue createQueue(CreateQueueRequest r) {
    auto service = services.findById(r.tenantId, MessagingServiceId(r.serviceId))
      .required("Messaging service '" ~ r.serviceId ~ "'");
    if (service.status == MessagingServiceStatus.deleting || service.status == MessagingServiceStatus.failed)
      throw EventsException.ruleViolation("Messaging service '" ~ service.name ~ "' is " ~ cast(string) service.status);
    EventQueue q;
    stampCreated!(EventQueue, QueueId)(q, r.tenantId, r.actor, r.id);
    if (queues.existsById(r.tenantId, q.id))
      throw EventsException.conflict("Queue '" ~ q.id.value ~ "' already exists");
    q.serviceId = service.id;
    q.name = r.name.strip;
    q.description = r.description;
    q.accessType = parseDomainEnumOr!QueueAccessType(r.accessType, QueueAccessType.nonExclusive, "accessType");
    q.maxDepth = r.maxDepth;
    q.maxMessageSize = r.maxMessageSize;
    q.messageTtlSeconds = r.messageTtlSeconds;
    q.maxRedeliveryCount = r.maxRedeliveryCount < 0 ? 3 : r.maxRedeliveryCount;
    q.deadLetterQueueId = QueueId(r.deadLetterQueueId);
    q.ingressEnabled = r.ingressEnabled;
    q.egressEnabled = r.egressEnabled;
    q.owner = r.owner.length > 0 ? r.owner : r.actor.value;
    q.validate();
    checkDeadLetterQueue(q);
    ensureUniqueName(q);
    auto quota = quotaOf(service).maxQueues;
    if (queues.findByService(r.tenantId, service.id).length >= quota)
      throw EventsException.quotaExceeded("Messaging service '" ~ service.name ~ "' allows " ~ countOf(quota, "queue"));
    queues.save(q);
    return q;
  }

  EventQueue updateQueue(UpdateQueueRequest r) {
    auto q = getQueue(r.tenantId, r.id);
    r.description.applyTo(q.description);
    applyEnum(r.status, q.status, "status");
    applyEnum(r.accessType, q.accessType, "accessType");
    r.maxDepth.applyTo(q.maxDepth);
    r.maxMessageSize.applyTo(q.maxMessageSize);
    r.messageTtlSeconds.applyTo(q.messageTtlSeconds);
    r.maxRedeliveryCount.applyTo(q.maxRedeliveryCount);
    if (r.deadLetterQueueId.isSet)
      q.deadLetterQueueId = QueueId(r.deadLetterQueueId.value);
    r.ingressEnabled.applyTo(q.ingressEnabled);
    r.egressEnabled.applyTo(q.egressEnabled);
    r.owner.applyTo(q.owner);
    q.validate();
    checkDeadLetterQueue(q);
    stampUpdated(q, r.actor);
    queues.save(q);
    return q;
  }

  void deleteQueue(TenantId tenantId, QueueId id) {
    auto q = getQueue(tenantId, id);
    if (auto n = webhooks.findByQueue(tenantId, id).length)
      throw EventsException.ruleViolation("Queue '" ~ q.name ~ "' is still pushed by " ~ countOf(n, "webhook"));
    if (auto n = queues.findByDeadLetterQueue(tenantId, id).length)
      throw EventsException.ruleViolation("Queue '" ~ q.name ~ "' is the dead letter queue of " ~ countOf(n, "queue"));
    foreach (s; subscriptions.findByQueue(tenantId, id))
      subscriptions.removeById(tenantId, s.id);
    foreach (b; bindings.findByQueue(tenantId, id))
      bindings.removeById(tenantId, b.id);
    messages.removeByQueue(tenantId, id);
    queues.removeById(tenantId, id);
  }

  protected void checkDeadLetterQueue(const EventQueue q) {
    if (q.deadLetterQueueId.isNull)
      return;
    auto dlq = queues.findById(q.tenantId, q.deadLetterQueueId).required("Dead letter queue '" ~ q.deadLetterQueueId.value ~ "'");
    if (dlq.serviceId != q.serviceId)
      throw EventsException.invalid("The dead letter queue must belong to the same messaging service");
    if (dlq.deadLetterQueueId == q.id)
      throw EventsException.invalid("Dead letter queues must not form a cycle");
  }

  protected void ensureUniqueName(const EventQueue q) {
    auto other = queues.findByName(q.tenantId, q.serviceId, q.name);
    if (!other.isNull && other.id != q.id)
      throw EventsException.conflict("A queue named '" ~ q.name ~ "' already exists for this service");
  }
}
