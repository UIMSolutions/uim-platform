/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/

/// Entity ↔ record mappers.
module uim.platform.events.persistence.mappers.entities;

import uim.platform.events;

mixin(ShowModule!());

@safe:

// ── MessagingService ──────────────────────────────────────────────────────
Json messagingServiceToRecord(const MessagingService e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["namespace"] = e.namespace;
  d["status"] = cast(string) e.status;
  d["plan"] = cast(string) e.plan;
  d["region"] = e.region;
  d["maxConnections"] = e.maxConnections;
  d["maxQueues"] = e.maxQueues;
  d["maxQueueDepth"] = e.maxQueueDepth;
  d["maxMessageSize"] = e.maxMessageSize;
  d["tokenEndpoint"] = e.tokenEndpoint;
  d["messagingEndpoint"] = e.messagingEndpoint;
  return d;
}

MessagingService recordToMessagingService(Json d) {
  MessagingService e;
  readAudit!(MessagingService, MessagingServiceId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.namespace = textField(d, "namespace");
  e.status = enumField(d, "status", MessagingServiceStatus.active);
  e.plan = enumField(d, "plan", MessagingServicePlan.standard);
  e.region = textField(d, "region");
  e.maxConnections = intField(d, "maxConnections");
  e.maxQueues = intField(d, "maxQueues");
  e.maxQueueDepth = intField(d, "maxQueueDepth");
  e.maxMessageSize = longField(d, "maxMessageSize");
  e.tokenEndpoint = textField(d, "tokenEndpoint");
  e.messagingEndpoint = textField(d, "messagingEndpoint");
  return e;
}

// ── MessageClient ─────────────────────────────────────────────────────────
Json messageClientToRecord(const MessageClient e) {
  auto d = auditRecord(e);
  d["serviceId"] = e.serviceId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["protocol"] = cast(string) e.protocol;
  d["clientId"] = e.clientId;
  d["clientSecret"] = e.clientSecret;
  d["tokenUrl"] = e.tokenUrl;
  d["permittedNamespace"] = e.permittedNamespace;
  return d;
}

MessageClient recordToMessageClient(Json d) {
  MessageClient e;
  readAudit!(MessageClient, MessageClientId)(e, d);
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", MessageClientStatus.active);
  e.protocol = enumField(d, "protocol", MessageClientProtocol.httprest);
  e.clientId = textField(d, "clientId");
  e.clientSecret = textField(d, "clientSecret");
  e.tokenUrl = textField(d, "tokenUrl");
  e.permittedNamespace = textField(d, "permittedNamespace");
  return e;
}

// ── EventQueue ────────────────────────────────────────────────────────────
Json queueToRecord(const EventQueue e) {
  auto d = auditRecord(e);
  d["serviceId"] = e.serviceId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["accessType"] = cast(string) e.accessType;
  d["maxDepth"] = e.maxDepth;
  d["maxMessageSize"] = e.maxMessageSize;
  d["messageTtlSeconds"] = e.messageTtlSeconds;
  d["maxRedeliveryCount"] = e.maxRedeliveryCount;
  d["deadLetterQueueId"] = e.deadLetterQueueId.value;
  d["ingressEnabled"] = e.ingressEnabled;
  d["egressEnabled"] = e.egressEnabled;
  d["owner"] = e.owner;
  return d;
}

EventQueue recordToEventQueue(Json d) {
  EventQueue e;
  readAudit!(EventQueue, QueueId)(e, d);
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", QueueStatus.active);
  e.accessType = enumField(d, "accessType", QueueAccessType.nonExclusive);
  e.maxDepth = intField(d, "maxDepth");
  e.maxMessageSize = longField(d, "maxMessageSize");
  e.messageTtlSeconds = longField(d, "messageTtlSeconds");
  e.maxRedeliveryCount = intField(d, "maxRedeliveryCount", 3);
  e.deadLetterQueueId = QueueId(textField(d, "deadLetterQueueId"));
  e.ingressEnabled = boolField(d, "ingressEnabled", true);
  e.egressEnabled = boolField(d, "egressEnabled", true);
  e.owner = textField(d, "owner");
  return e;
}

// ── QueueSubscription ─────────────────────────────────────────────────────
Json queueSubscriptionToRecord(const QueueSubscription e) {
  auto d = auditRecord(e);
  d["queueId"] = e.queueId.value;
  d["serviceId"] = e.serviceId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["topicPattern"] = e.topicPattern;
  return d;
}

QueueSubscription recordToQueueSubscription(Json d) {
  QueueSubscription e;
  readAudit!(QueueSubscription, QueueSubscriptionId)(e, d);
  e.queueId = QueueId(textField(d, "queueId"));
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", QueueSubscriptionStatus.active);
  e.topicPattern = textField(d, "topicPattern");
  return e;
}

// ── Webhook ───────────────────────────────────────────────────────────────
Json webhookToRecord(const Webhook e) {
  auto d = auditRecord(e);
  d["serviceId"] = e.serviceId.value;
  d["queueId"] = e.queueId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["url"] = e.url;
  d["headers"] = e.headers;
  d["exemptHandshake"] = e.exemptHandshake;
  d["authenticationType"] = cast(string) e.authenticationType;
  d["credentials"] = e.credentials;
  d["tokenUrl"] = e.tokenUrl;
  d["clientId"] = e.clientId;
  d["deliveryMode"] = cast(string) e.deliveryMode;
  d["batchSize"] = e.batchSize;
  d["deliveredCount"] = e.deliveredCount;
  d["failedCount"] = e.failedCount;
  d["lastDeliveryAt"] = e.lastDeliveryAt;
  d["lastError"] = e.lastError;
  return d;
}

Webhook recordToWebhook(Json d) {
  Webhook e;
  readAudit!(Webhook, WebhookId)(e, d);
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.queueId = QueueId(textField(d, "queueId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", WebhookStatus.active);
  e.url = textField(d, "url");
  e.headers = textField(d, "headers");
  e.exemptHandshake = boolField(d, "exemptHandshake", false);
  e.authenticationType = enumField(d, "authenticationType", WebhookAuthType.none);
  e.credentials = textField(d, "credentials");
  e.tokenUrl = textField(d, "tokenUrl");
  e.clientId = textField(d, "clientId");
  e.deliveryMode = enumField(d, "deliveryMode", WebhookDeliveryMode.atLeastOnce);
  e.batchSize = intField(d, "batchSize", 10);
  e.deliveredCount = longField(d, "deliveredCount");
  e.failedCount = longField(d, "failedCount");
  e.lastDeliveryAt = longField(d, "lastDeliveryAt");
  e.lastError = textField(d, "lastError");
  return e;
}

// ── EventChannel ──────────────────────────────────────────────────────────
Json eventChannelToRecord(const EventChannel e) {
  auto d = auditRecord(e);
  d["serviceId"] = e.serviceId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["channelType"] = cast(string) e.channelType;
  d["topicName"] = e.topicName;
  d["asyncapiDefinition"] = e.asyncapiDefinition;
  d["retentionHours"] = e.retentionHours;
  d["partitions"] = e.partitions;
  return d;
}

EventChannel recordToEventChannel(Json d) {
  EventChannel e;
  readAudit!(EventChannel, EventChannelId)(e, d);
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", EventChannelStatus.active);
  e.channelType = enumField(d, "channelType", EventChannelType.topic);
  e.topicName = textField(d, "topicName");
  e.asyncapiDefinition = textField(d, "asyncapiDefinition");
  e.retentionHours = intField(d, "retentionHours");
  e.partitions = intField(d, "partitions", 1);
  return e;
}

// ── MessageBinding ────────────────────────────────────────────────────────
Json messageBindingToRecord(const MessageBinding e) {
  auto d = auditRecord(e);
  d["clientId"] = e.clientId.value;
  d["serviceId"] = e.serviceId.value;
  d["queueId"] = e.queueId.value;
  d["channelId"] = e.channelId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  d["permission"] = cast(string) e.permission;
  return d;
}

MessageBinding recordToMessageBinding(Json d) {
  MessageBinding e;
  readAudit!(MessageBinding, MessageBindingId)(e, d);
  e.clientId = MessageClientId(textField(d, "clientId"));
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.queueId = QueueId(textField(d, "queueId"));
  e.channelId = EventChannelId(textField(d, "channelId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", MessageBindingStatus.active);
  e.permission = enumField(d, "permission", MessageBindingPermission.publishSubscribe);
  return e;
}

// ── QueueMessage ──────────────────────────────────────────────────────────
Json queueMessageToRecord(const QueueMessage e) {
  auto d = auditRecord(e);
  d["queueId"] = e.queueId.value;
  d["serviceId"] = e.serviceId.value;
  d["correlationId"] = e.correlationId;
  d["topic"] = e.topic;
  d["payload"] = e.payload;
  d["contentType"] = e.contentType;
  d["state"] = cast(string) e.state;
  d["deliveryCount"] = e.deliveryCount;
  d["expiresAt"] = e.expiresAt;
  d["publisherId"] = e.publisherId.value;
  d["originalQueueId"] = e.originalQueueId.value;
  d["lastError"] = e.lastError;
  return d;
}

QueueMessage recordToQueueMessage(Json d) {
  QueueMessage e;
  readAudit!(QueueMessage, QueueMessageId)(e, d);
  e.queueId = QueueId(textField(d, "queueId"));
  e.serviceId = MessagingServiceId(textField(d, "serviceId"));
  e.correlationId = textField(d, "correlationId");
  e.topic = textField(d, "topic");
  e.payload = textField(d, "payload");
  e.contentType = textField(d, "contentType");
  e.state = enumField(d, "state", QueueMessageState.queued);
  e.deliveryCount = intField(d, "deliveryCount");
  e.expiresAt = longField(d, "expiresAt");
  e.publisherId = MessageClientId(textField(d, "publisherId"));
  e.originalQueueId = QueueId(textField(d, "originalQueueId"));
  e.lastError = textField(d, "lastError");
  return e;
}

///
unittest {
  EventQueue q;
  q.id = QueueId("q1");
  q.tenantId = TenantId("t");
  q.serviceId = MessagingServiceId("s");
  q.name = "a/b/c";
  q.status = QueueStatus.inactive;
  q.deadLetterQueueId = QueueId("dlq");
  q.maxRedeliveryCount = 7;
  q.ingressEnabled = false;
  auto back = recordToEventQueue(queueToRecord(q));
  assert(back == q);

  auto legacy = Json.emptyObject;
  legacy["id"] = "x";
  legacy["status"] = "unknownValue";
  auto e = recordToEventQueue(legacy);
  assert(e.status == QueueStatus.active && e.maxRedeliveryCount == 3 && e.egressEnabled);
}
