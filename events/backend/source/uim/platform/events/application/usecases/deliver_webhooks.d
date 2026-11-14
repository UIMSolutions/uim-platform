/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.deliver_webhooks;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Push delivery: send the oldest messages of the webhook's queue to its
/// endpoint; failed messages are retried up to the queue's
/// maxRedeliveryCount and then dead-lettered (or discarded).
class DeliverWebhooksUseCase : IDeliverWebhooks {
  protected IWebhookRepository webhooks;
  protected IQueueRepository queues;
  protected IQueueMessageRepository messages;
  protected IWebhookEndpointGateway gateway;

  this(IWebhookRepository webhooks, IQueueRepository queues, IQueueMessageRepository messages, IWebhookEndpointGateway gateway) {
    this.webhooks = webhooks;
    this.queues = queues;
    this.messages = messages;
    this.gateway = gateway;
  }

  DeliveryResult deliver(TenantId tenantId, WebhookId id, UserId actor) {
    auto w = webhooks.findById(tenantId, id).required("Webhook '" ~ id.value ~ "'");
    if (!w.isActive)
      throw EventsException.ruleViolation("Webhook '" ~ w.name ~ "' is " ~ cast(string) w.status);
    return run(w);
  }

  DeliveryResult[] deliverAll(TenantId tenantId, UserId actor) {
    DeliveryResult[] results;
    foreach (w; webhooks.findAll(tenantId))
      if (w.isActive)
        results ~= run(w);
    return results;
  }

  protected DeliveryResult run(Webhook w) {
    DeliveryResult result;
    result.webhookId = w.id.value;
    result.webhookName = w.name;
    auto q = queues.findById(w.tenantId, w.queueId);
    if (q.isNull || !q.deliversMessages) {
      result.lastError = "queue not available for delivery";
      return result;
    }

    auto now = nowStdTime();
    foreach (m; messages.findByQueue(w.tenantId, q.id)) {
      if (result.attempted >= cast(size_t) w.batchSize)
        break;
      if (m.isExpired(now)) {
        messages.removeById(w.tenantId, m.id);
        continue;
      }
      result.attempted++;
      auto response = gateway.push(requestFor(w, m));
      final switch (deliveryOutcome(response.succeeded, m, q, w.deliveryMode)) {
      case DeliveryOutcome.remove:
        messages.removeById(w.tenantId, m.id);
        if (response.succeeded)
          result.delivered++;
        else
          result.discarded++;
        break;
      case DeliveryOutcome.retry:
        m.deliveryCount++;
        m.lastError = describe(response);
        m.updatedAt = now;
        messages.save(m);
        result.retried++;
        break;
      case DeliveryOutcome.deadLetter:
        moveToDeadLetterQueue(m, q, describe(response), now);
        result.deadLettered++;
        break;
      case DeliveryOutcome.discard:
        messages.removeById(w.tenantId, m.id);
        result.discarded++;
        break;
      }
      if (!response.succeeded)
        result.lastError = describe(response);
    }

    if (result.attempted > 0) {
      w.deliveredCount += result.delivered;
      w.failedCount += result.attempted - result.delivered;
      w.lastDeliveryAt = now;
      w.lastError = result.lastError;
      webhooks.save(w);
    }
    return result;
  }

  protected void moveToDeadLetterQueue(QueueMessage m, const EventQueue q, string error, long now) {
    messages.removeById(m.tenantId, m.id);
    m.originalQueueId = q.id;
    m.queueId = q.deadLetterQueueId;
    m.state = QueueMessageState.deadLettered;
    m.deliveryCount++;
    m.lastError = error;
    m.updatedAt = now;
    messages.save(m);
  }

  protected static WebhookRequest requestFor(const Webhook w, const QueueMessage m) {
    WebhookRequest r;
    r.url = w.url;
    r.headers = w.headerMap();
    r.headers["X-Event-Topic"] = m.topic;
    r.headers["X-Message-Id"] = m.correlationId.length > 0 ? m.correlationId : m.id.value;
    r.contentType = m.contentType;
    r.body = m.payload;
    r.authenticationType = w.authenticationType;
    r.credentials = w.credentials;
    r.tokenUrl = w.tokenUrl;
    r.clientId = w.clientId;
    return r;
  }

  protected static string describe(const WebhookResponse r) {
    if (r.succeeded)
      return "";
    return r.status == 0 ? r.error : format("HTTP %d%s", r.status, r.error.length ? ": " ~ r.error : "");
  }
}
