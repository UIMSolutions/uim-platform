/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_queue_subscriptions;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageQueueSubscriptionsUseCase : IManageQueueSubscriptions {
  protected IQueueSubscriptionRepository subscriptions;
  protected IQueueRepository queues;
  protected IMessagingServiceRepository services;

  this(IQueueSubscriptionRepository subscriptions, IQueueRepository queues, IMessagingServiceRepository services) {
    this.subscriptions = subscriptions;
    this.queues = queues;
    this.services = services;
  }

  QueueSubscription[] listQueueSubscriptions(TenantId tenantId) {
    return subscriptions.findAll(tenantId);
  }

  QueueSubscription getQueueSubscription(TenantId tenantId, QueueSubscriptionId id) {
    return subscriptions.findById(tenantId, id).required("Queue subscription '" ~ id.value ~ "'");
  }

  QueueSubscription createQueueSubscription(CreateQueueSubscriptionRequest r) {
    auto queue = queues.findById(r.tenantId, QueueId(r.queueId)).required("Queue '" ~ r.queueId ~ "'");
    QueueSubscription s;
    stampCreated!(QueueSubscription, QueueSubscriptionId)(s, r.tenantId, r.actor, r.id);
    if (subscriptions.existsById(r.tenantId, s.id))
      throw EventsException.conflict("Queue subscription '" ~ s.id.value ~ "' already exists");
    s.queueId = queue.id;
    s.serviceId = queue.serviceId;
    s.topicPattern = r.topicPattern.strip;
    s.name = r.name.strip.length > 0 ? r.name.strip : s.topicPattern;
    s.description = r.description;
    s.validate();
    checkPattern(s);
    subscriptions.save(s);
    return s;
  }

  QueueSubscription updateQueueSubscription(UpdateQueueSubscriptionRequest r) {
    auto s = getQueueSubscription(r.tenantId, r.id);
    r.name.applyTo(s.name);
    r.description.applyTo(s.description);
    applyEnum(r.status, s.status, "status");
    if (r.topicPattern.isSet)
      s.topicPattern = r.topicPattern.value.strip;
    s.validate();
    checkPattern(s);
    stampUpdated(s, r.actor);
    subscriptions.save(s);
    return s;
  }

  void deleteQueueSubscription(TenantId tenantId, QueueSubscriptionId id) {
    getQueueSubscription(tenantId, id);
    subscriptions.removeById(tenantId, id);
  }

  protected void checkPattern(const QueueSubscription s) {
    auto service = services.findById(s.tenantId, s.serviceId).required("Messaging service");
    if (!isPatternInNamespace(s.topicPattern, service.namespace))
      throw EventsException.invalid("Topic pattern '" ~ s.topicPattern ~ "' is outside namespace '" ~ service.namespace ~ "'");
    foreach (other; subscriptions.findByQueue(s.tenantId, s.queueId))
      if (other.id != s.id && other.topicPattern == s.topicPattern)
        throw EventsException.conflict("The queue already subscribes to '" ~ s.topicPattern ~ "'");
  }
}
