/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.events.presentation.odata.payloads;

import uim.platform.events;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool boolOf(Json p, string key, bool fallback = false) {
  return key in p && p[key].type == Json.Type.bool_ ? p[key].get!bool : fallback;
}

long longOf(Json p, string key, long fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.to!long;
    catch (Exception) {
    }
  }
  return fallback;
}

int intOf(Json p, string key, int fallback = 0) {
  return cast(int) longOf(p, key, fallback);
}

/// Present (incl. null → "") or unset.
Patch!string textPatch(Json p, string key) {
  Patch!string r;
  if (key in p)
    r = textOf(p, key);
  return r;
}

Patch!bool boolPatch(Json p, string key) {
  Patch!bool r;
  if (key in p && p[key].type == Json.Type.bool_)
    r = p[key].get!bool;
  return r;
}

Patch!int intPatch(Json p, string key) {
  Patch!int r;
  if (key in p)
    r = intOf(p, key);
  return r;
}

Patch!long longPatch(Json p, string key) {
  Patch!long r;
  if (key in p)
    r = longOf(p, key);
  return r;
}


// ── Messaging services ──────────────────────────────────────────────────────
CreateMessagingServiceRequest createMessagingServiceRequest(const RequestContext ctx, Json p) {
  CreateMessagingServiceRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.namespace = textOf(p, "namespace");
  r.plan = textOf(p, "plan");
  r.region = textOf(p, "region");
  r.maxConnections = intOf(p, "maxConnections");
  r.maxQueues = intOf(p, "maxQueues");
  r.maxQueueDepth = intOf(p, "maxQueueDepth");
  r.maxMessageSize = longOf(p, "maxMessageSize");
  r.tokenEndpoint = textOf(p, "tokenEndpoint");
  r.messagingEndpoint = textOf(p, "messagingEndpoint");
  return r;
}

UpdateMessagingServiceRequest updateMessagingServiceRequest(const RequestContext ctx, string key, Json p) {
  UpdateMessagingServiceRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = MessagingServiceId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.plan = textPatch(p, "plan");
  r.region = textPatch(p, "region");
  r.maxConnections = intPatch(p, "maxConnections");
  r.maxQueues = intPatch(p, "maxQueues");
  r.maxQueueDepth = intPatch(p, "maxQueueDepth");
  r.maxMessageSize = longPatch(p, "maxMessageSize");
  r.tokenEndpoint = textPatch(p, "tokenEndpoint");
  r.messagingEndpoint = textPatch(p, "messagingEndpoint");
  return r;
}

// ── Message clients ─────────────────────────────────────────────────────────
CreateMessageClientRequest createMessageClientRequest(const RequestContext ctx, Json p) {
  CreateMessageClientRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.serviceId = textOf(p, "serviceId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.protocol = textOf(p, "protocol");
  r.clientId = textOf(p, "clientId");
  r.clientSecret = textOf(p, "clientSecret");
  r.tokenUrl = textOf(p, "tokenUrl");
  r.permittedNamespace = textOf(p, "permittedNamespace");
  return r;
}

UpdateMessageClientRequest updateMessageClientRequest(const RequestContext ctx, string key, Json p) {
  UpdateMessageClientRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = MessageClientId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.protocol = textPatch(p, "protocol");
  if (textOf(p, "clientSecret").length > 0) // null / "" keeps the secret
    r.clientSecret = textOf(p, "clientSecret");
  r.tokenUrl = textPatch(p, "tokenUrl");
  r.permittedNamespace = textPatch(p, "permittedNamespace");
  return r;
}

// ── Queues ──────────────────────────────────────────────────────────────────
CreateQueueRequest createQueueRequest(const RequestContext ctx, Json p) {
  CreateQueueRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.serviceId = textOf(p, "serviceId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.accessType = textOf(p, "accessType");
  r.maxDepth = intOf(p, "maxDepth");
  r.maxMessageSize = longOf(p, "maxMessageSize");
  r.messageTtlSeconds = longOf(p, "messageTtlSeconds");
  r.maxRedeliveryCount = intOf(p, "maxRedeliveryCount", -1);
  r.deadLetterQueueId = textOf(p, "deadLetterQueueId");
  r.ingressEnabled = boolOf(p, "ingressEnabled", true);
  r.egressEnabled = boolOf(p, "egressEnabled", true);
  r.owner = textOf(p, "owner");
  return r;
}

UpdateQueueRequest updateQueueRequest(const RequestContext ctx, string key, Json p) {
  UpdateQueueRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = QueueId(key);
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.accessType = textPatch(p, "accessType");
  r.maxDepth = intPatch(p, "maxDepth");
  r.maxMessageSize = longPatch(p, "maxMessageSize");
  r.messageTtlSeconds = longPatch(p, "messageTtlSeconds");
  r.maxRedeliveryCount = intPatch(p, "maxRedeliveryCount");
  r.deadLetterQueueId = textPatch(p, "deadLetterQueueId");
  r.ingressEnabled = boolPatch(p, "ingressEnabled");
  r.egressEnabled = boolPatch(p, "egressEnabled");
  r.owner = textPatch(p, "owner");
  return r;
}

// ── Queue subscriptions ─────────────────────────────────────────────────────
CreateQueueSubscriptionRequest createQueueSubscriptionRequest(const RequestContext ctx, Json p) {
  CreateQueueSubscriptionRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.queueId = textOf(p, "queueId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.topicPattern = textOf(p, "topicPattern");
  return r;
}

UpdateQueueSubscriptionRequest updateQueueSubscriptionRequest(const RequestContext ctx, string key, Json p) {
  UpdateQueueSubscriptionRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = QueueSubscriptionId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.topicPattern = textPatch(p, "topicPattern");
  return r;
}

// ── Webhooks ────────────────────────────────────────────────────────────────
CreateWebhookRequest createWebhookRequest(const RequestContext ctx, Json p) {
  CreateWebhookRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.queueId = textOf(p, "queueId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.url = textOf(p, "url");
  r.headers = textOf(p, "headers");
  r.exemptHandshake = boolOf(p, "exemptHandshake");
  r.authenticationType = textOf(p, "authenticationType");
  r.credentials = textOf(p, "credentials");
  r.tokenUrl = textOf(p, "tokenUrl");
  r.clientId = textOf(p, "clientId");
  r.deliveryMode = textOf(p, "deliveryMode");
  r.batchSize = intOf(p, "batchSize");
  return r;
}

UpdateWebhookRequest updateWebhookRequest(const RequestContext ctx, string key, Json p) {
  UpdateWebhookRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = WebhookId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.url = textPatch(p, "url");
  r.headers = textPatch(p, "headers");
  r.exemptHandshake = boolPatch(p, "exemptHandshake");
  r.authenticationType = textPatch(p, "authenticationType");
  if (textOf(p, "credentials").length > 0) // null / "" keeps the secret
    r.credentials = textOf(p, "credentials");
  r.tokenUrl = textPatch(p, "tokenUrl");
  r.clientId = textPatch(p, "clientId");
  r.deliveryMode = textPatch(p, "deliveryMode");
  r.batchSize = intPatch(p, "batchSize");
  return r;
}

// ── Event channels ──────────────────────────────────────────────────────────
CreateEventChannelRequest createEventChannelRequest(const RequestContext ctx, Json p) {
  CreateEventChannelRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.serviceId = textOf(p, "serviceId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.channelType = textOf(p, "channelType");
  r.topicName = textOf(p, "topicName");
  r.asyncapiDefinition = textOf(p, "asyncapiDefinition");
  r.retentionHours = intOf(p, "retentionHours");
  r.partitions = intOf(p, "partitions");
  return r;
}

UpdateEventChannelRequest updateEventChannelRequest(const RequestContext ctx, string key, Json p) {
  UpdateEventChannelRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = EventChannelId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.channelType = textPatch(p, "channelType");
  r.asyncapiDefinition = textPatch(p, "asyncapiDefinition");
  r.retentionHours = intPatch(p, "retentionHours");
  r.partitions = intPatch(p, "partitions");
  return r;
}

// ── Message bindings ────────────────────────────────────────────────────────
CreateMessageBindingRequest createMessageBindingRequest(const RequestContext ctx, Json p) {
  CreateMessageBindingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.clientId = textOf(p, "clientId");
  r.queueId = textOf(p, "queueId");
  r.channelId = textOf(p, "channelId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.permission = textOf(p, "permission");
  return r;
}

UpdateMessageBindingRequest updateMessageBindingRequest(const RequestContext ctx, string key, Json p) {
  UpdateMessageBindingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = MessageBindingId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.permission = textPatch(p, "permission");
  return r;
}

// ── Actions ─────────────────────────────────────────────────────────────────
PublishEventRequest publishEventRequest(const RequestContext ctx, Json p) {
  PublishEventRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.serviceId = textOf(p, "serviceId");
  r.clientId = textOf(p, "clientId");
  r.topic = textOf(p, "topic");
  r.payload = textOf(p, "payload");
  if (textOf(p, "contentType").length > 0)
    r.contentType = textOf(p, "contentType");
  return r;
}

ConsumeMessagesRequest consumeMessagesRequest(const RequestContext ctx, Json p) {
  ConsumeMessagesRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.queueId = QueueId(textOf(p, "queueId"));
  r.clientId = textOf(p, "clientId");
  r.maxMessages = intOf(p, "maxMessages", 10);
  return r;
}

///
unittest {
  auto p = Json.emptyObject;
  p["description"] = Json(null);
  p["maxDepth"] = "42";
  RequestContext ctx;
  ctx.tenantId = "t";
  auto r = updateQueueRequest(ctx, "q", p);
  assert(r.description.isSet && r.description.value == "");
  assert(r.maxDepth.isSet && r.maxDepth.value == 42);
  assert(!r.status.isSet && r.tenantId.value == "t" && r.id.value == "q");
}
