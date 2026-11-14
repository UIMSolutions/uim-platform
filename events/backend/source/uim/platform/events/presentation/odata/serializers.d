/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Secrets
/// (client secrets, webhook credentials) are never serialized (write-only).
module uim.platform.events.presentation.odata.serializers;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime - stdTime % hnsecsPerSecond, UTC());
  return Json(t.toISOExtString);
}

Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

/// Empty id → null (optional references).
private Json idOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

private Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

Json messagingServiceRow(const MessagingService e, size_t clients = 0, size_t queues = 0, size_t channels = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["namespace"] = e.namespace;
  j["status"] = cast(string) e.status;
  j["plan"] = cast(string) e.plan;
  j["region"] = e.region;
  auto q = quotaOf(e); // effective limits
  j["maxConnections"] = q.maxConnections;
  j["maxQueues"] = q.maxQueues;
  j["maxQueueDepth"] = q.maxQueueDepth;
  j["maxMessageSize"] = q.maxMessageSize;
  j["tokenEndpoint"] = e.tokenEndpoint;
  j["messagingEndpoint"] = e.messagingEndpoint;
  j["clientCount"] = clients;
  j["queueCount"] = queues;
  j["channelCount"] = channels;
  return j;
}

Json messageClientRow(const MessageClient e, size_t bindings = 0) {
  auto j = auditRow(e);
  j["serviceId"] = e.serviceId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["protocol"] = cast(string) e.protocol;
  j["clientId"] = e.clientId;
  j["clientSecret"] = Json(null);
  j["hasSecret"] = e.clientSecret.length > 0;
  j["tokenUrl"] = e.tokenUrl;
  j["permittedNamespace"] = e.permittedNamespace;
  j["bindingCount"] = bindings;
  return j;
}

Json queueRow(const EventQueue e, size_t messages = 0, size_t subscriptions = 0, size_t webhooks = 0) {
  auto j = auditRow(e);
  j["serviceId"] = e.serviceId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["accessType"] = cast(string) e.accessType;
  j["maxDepth"] = e.maxDepth;
  j["maxMessageSize"] = e.maxMessageSize;
  j["messageTtlSeconds"] = e.messageTtlSeconds;
  j["maxRedeliveryCount"] = e.maxRedeliveryCount;
  j["deadLetterQueueId"] = idOrNull(e.deadLetterQueueId.value);
  j["ingressEnabled"] = e.ingressEnabled;
  j["egressEnabled"] = e.egressEnabled;
  j["owner"] = e.owner;
  j["messageCount"] = messages;
  j["subscriptionCount"] = subscriptions;
  j["webhookCount"] = webhooks;
  return j;
}

Json queueSubscriptionRow(const QueueSubscription e) {
  auto j = auditRow(e);
  j["queueId"] = e.queueId.value;
  j["serviceId"] = e.serviceId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["topicPattern"] = e.topicPattern;
  return j;
}

Json webhookRow(const Webhook e) {
  auto j = auditRow(e);
  j["queueId"] = e.queueId.value;
  j["serviceId"] = e.serviceId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["url"] = e.url;
  j["headers"] = e.headers;
  j["exemptHandshake"] = e.exemptHandshake;
  j["authenticationType"] = cast(string) e.authenticationType;
  j["credentials"] = Json(null);
  j["hasCredentials"] = e.credentials.length > 0;
  j["tokenUrl"] = e.tokenUrl;
  j["clientId"] = e.clientId;
  j["deliveryMode"] = cast(string) e.deliveryMode;
  j["batchSize"] = e.batchSize;
  j["deliveredCount"] = e.deliveredCount;
  j["failedCount"] = e.failedCount;
  j["lastDeliveryAt"] = isoTime(e.lastDeliveryAt);
  j["lastError"] = e.lastError;
  return j;
}

Json eventChannelRow(const EventChannel e, size_t bindings = 0) {
  auto j = auditRow(e);
  j["serviceId"] = e.serviceId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["channelType"] = cast(string) e.channelType;
  j["topicName"] = e.topicName;
  j["asyncapiDefinition"] = e.asyncapiDefinition;
  j["retentionHours"] = e.retentionHours;
  j["partitions"] = e.partitions;
  j["bindingCount"] = bindings;
  return j;
}

Json messageBindingRow(const MessageBinding e) {
  auto j = auditRow(e);
  j["clientId"] = e.clientId.value;
  j["serviceId"] = e.serviceId.value;
  j["queueId"] = idOrNull(e.queueId.value);
  j["channelId"] = idOrNull(e.channelId.value);
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["permission"] = cast(string) e.permission;
  return j;
}

Json queueMessageRow(const QueueMessage e) {
  auto j = auditRow(e);
  j["queueId"] = e.queueId.value;
  j["serviceId"] = e.serviceId.value;
  j["correlationId"] = e.correlationId;
  j["topic"] = e.topic;
  j["payload"] = e.payload;
  j["contentType"] = e.contentType;
  j["state"] = cast(string) e.state;
  j["size"] = e.size;
  j["deliveryCount"] = e.deliveryCount;
  j["expiresAt"] = isoTime(e.expiresAt);
  j["publisherId"] = idOrNull(e.publisherId.value);
  j["originalQueueId"] = idOrNull(e.originalQueueId.value);
  j["lastError"] = e.lastError;
  return j;
}

Json statisticsRow(const EventsStatistics s) {
  auto j = Json.emptyObject;
  static foreach (name; ["tenantId", "services", "activeServices", "clients", "queues", "subscriptions", "webhooks",
      "failingWebhooks", "channels", "bindings", "queuedMessages", "deadLetteredMessages", "deliveredMessages"])
    j[name] = __traits(getMember, s, name);
  return j;
}

Json publishResultRow(const PublishResult r) {
  auto j = Json.emptyObject;
  j["messageId"] = r.messageId;
  j["topic"] = r.topic;
  j["delivered"] = r.queueIds.length;
  j["queueIds"] = texts(r.queueIds);
  j["rejectedQueueIds"] = texts(r.rejectedQueueIds);
  return j;
}

Json deliveryResultRow(const DeliveryResult r) {
  auto j = Json.emptyObject;
  static foreach (name; ["webhookId", "webhookName", "attempted", "delivered", "retried", "deadLettered", "discarded", "lastError"])
    j[name] = __traits(getMember, r, name);
  return j;
}

Json purgeResultRow(string queueId, size_t removed) {
  auto j = Json.emptyObject;
  j["queueId"] = queueId;
  j["removed"] = removed;
  return j;
}

///
unittest {
  MessageClient c;
  c.id = MessageClientId("c");
  c.clientSecret = "s3cr3t";
  auto row = messageClientRow(c);
  assert(row["clientSecret"].type == Json.Type.null_ && row["hasSecret"].get!bool);
  assert(isoTime(0).type == Json.Type.null_);
  assert(!row.toString.canFind("s3cr3t"));
}
