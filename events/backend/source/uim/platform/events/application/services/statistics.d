/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.services.statistics;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Tenant wide counters for dashboards (Fiori KPI header, CLI stats, GUI).
class EventsStatisticsService : IEventsStatistics {
  protected IMessagingServiceRepository services;
  protected IMessageClientRepository clients;
  protected IQueueRepository queues;
  protected IQueueSubscriptionRepository subscriptions;
  protected IWebhookRepository webhooks;
  protected IEventChannelRepository channels;
  protected IMessageBindingRepository bindings;
  protected IQueueMessageRepository messages;

  this(IMessagingServiceRepository services, IMessageClientRepository clients, IQueueRepository queues,
    IQueueSubscriptionRepository subscriptions, IWebhookRepository webhooks, IEventChannelRepository channels,
    IMessageBindingRepository bindings, IQueueMessageRepository messages) {
    this.services = services;
    this.clients = clients;
    this.queues = queues;
    this.subscriptions = subscriptions;
    this.webhooks = webhooks;
    this.channels = channels;
    this.bindings = bindings;
    this.messages = messages;
  }

  EventsStatistics compute(TenantId t) {
    EventsStatistics s;
    s.tenantId = t.value;
    auto all = services.findAll(t);
    s.services = all.length;
    s.activeServices = all.count!(e => e.isActive);
    s.clients = clients.countAll(t);
    s.queues = queues.countAll(t);
    s.subscriptions = subscriptions.countAll(t);
    s.channels = channels.countAll(t);
    s.bindings = bindings.countAll(t);
    foreach (w; webhooks.findAll(t)) {
      s.webhooks++;
      if (w.lastError.length > 0 || w.status == WebhookStatus.failed)
        s.failingWebhooks++;
      s.deliveredMessages += w.deliveredCount;
    }
    auto now = nowStdTime();
    foreach (m; messages.findAll(t)) {
      if (m.isExpired(now))
        continue;
      if (m.state == QueueMessageState.deadLettered)
        s.deadLetteredMessages++;
      else
        s.queuedMessages++;
    }
    return s;
  }
}
