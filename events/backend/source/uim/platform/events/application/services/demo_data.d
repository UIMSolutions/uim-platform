/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant (CLI "seed", GUI, local Fiori development).
module uim.platform.events.application.services.demo_data;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct DemoDataResult {
  size_t services;
  size_t clients;
  size_t queues;
  size_t subscriptions;
  size_t webhooks;
  size_t channels;
  size_t bindings;
  size_t messages;
}

/// Seed a sales order scenario through the driving ports (so every business
/// rule applies). Refused (conflict) if the tenant already has services.
DemoDataResult seedDemoData(EventsPorts ports, TenantId t, UserId actor) {
  if (ports.services.listMessagingServices(t).length > 0)
    throw EventsException.conflict("Tenant '" ~ t.value ~ "' is not empty");
  DemoDataResult r;

  CreateMessagingServiceRequest s;
  s.tenantId = t;
  s.actor = actor;
  s.id = "sales-orders";
  s.name = "Sales Orders";
  s.description = "Order lifecycle events of the sales application";
  s.namespace = "acme/sales/orders";
  s.plan = "standard";
  s.region = "eu10";
  auto service = ports.services.createMessagingService(s);
  r.services++;

  CreateMessagingServiceRequest s2 = s;
  s2.id = "logistics";
  s2.name = "Logistics";
  s2.description = "Shipment tracking";
  s2.namespace = "acme/logistics/shipments";
  s2.plan = "dev";
  ports.services.createMessagingService(s2);
  r.services++;

  CreateQueueRequest dlq;
  dlq.tenantId = t;
  dlq.actor = actor;
  dlq.id = "orders-dlq";
  dlq.serviceId = service.id.value;
  dlq.name = "acme/sales/orders/dlq";
  dlq.description = "Dead letter queue of the order queues";
  ports.queues.createQueue(dlq);
  r.queues++;

  CreateQueueRequest q = dlq;
  q.id = "orders-created";
  q.name = "acme/sales/orders/created";
  q.description = "New orders for the ERP integration";
  q.deadLetterQueueId = "orders-dlq";
  q.maxRedeliveryCount = 3;
  q.messageTtlSeconds = 7 * 24 * 3600;
  ports.queues.createQueue(q);
  r.queues++;

  CreateQueueRequest audit = dlq;
  audit.id = "orders-audit";
  audit.name = "acme/sales/orders/audit";
  audit.description = "Copy of every order event";
  ports.queues.createQueue(audit);
  r.queues++;

  foreach (sub; [["orders-created", "acme/sales/orders/ce/created"], ["orders-audit", "acme/sales/orders/#"]]) {
    CreateQueueSubscriptionRequest qs;
    qs.tenantId = t;
    qs.actor = actor;
    qs.queueId = sub[0];
    qs.topicPattern = sub[1];
    ports.subscriptions.createQueueSubscription(qs);
    r.subscriptions++;
  }

  foreach (ch; [["order-created", "Order created", "acme/sales/orders/ce/created"],
      ["order-cancelled", "Order cancelled", "acme/sales/orders/ce/cancelled"]]) {
    CreateEventChannelRequest c;
    c.tenantId = t;
    c.actor = actor;
    c.id = ch[0];
    c.serviceId = service.id.value;
    c.name = ch[1];
    c.topicName = ch[2];
    c.retentionHours = 24;
    ports.channels.createEventChannel(c);
    r.channels++;
  }

  CreateMessageClientRequest shop;
  shop.tenantId = t;
  shop.actor = actor;
  shop.id = "webshop";
  shop.serviceId = service.id.value;
  shop.name = "Web Shop";
  shop.description = "Publishes order events";
  shop.protocol = "httprest";
  ports.clients.createMessageClient(shop);
  r.clients++;

  CreateMessageClientRequest erp = shop;
  erp.id = "erp";
  erp.name = "ERP Connector";
  erp.description = "Consumes new orders";
  erp.protocol = "amqp10";
  ports.clients.createMessageClient(erp);
  r.clients++;

  foreach (b; [["webshop", "", "order-created", "publish"], ["webshop", "", "order-cancelled", "publish"],
      ["erp", "orders-created", "", "subscribe"]]) {
    CreateMessageBindingRequest mb;
    mb.tenantId = t;
    mb.actor = actor;
    mb.clientId = b[0];
    mb.queueId = b[1];
    mb.channelId = b[2];
    mb.permission = b[3];
    ports.bindings.createMessageBinding(mb);
    r.bindings++;
  }

  CreateWebhookRequest w;
  w.tenantId = t;
  w.actor = actor;
  w.id = "erp-webhook";
  w.queueId = "orders-created";
  w.name = "ERP order inbox";
  w.description = "Paused demo endpoint — set a reachable URL and activate it";
  w.url = "https://erp.example.com/api/order-events";
  w.headers = `{"X-Source": "uim-event-mesh"}`;
  ports.webhooks.createWebhook(w);
  UpdateWebhookRequest pause;
  pause.tenantId = t;
  pause.actor = actor;
  pause.id = WebhookId("erp-webhook");
  pause.status = "paused";
  ports.webhooks.updateWebhook(pause);
  r.webhooks++;

  foreach (i, e; [["created", `{"orderId": "4711", "amount": 99.5}`], ["created", `{"orderId": "4712", "amount": 12}`],
      ["cancelled", `{"orderId": "4700"}`]]) {
    PublishEventRequest p;
    p.tenantId = t;
    p.actor = actor;
    p.clientId = "webshop";
    p.topic = "acme/sales/orders/ce/" ~ e[0];
    p.payload = e[1];
    r.messages += ports.publisher.publish(p).queueIds.length;
  }
  return r;
}
