/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST
/// adapter, the CLI and the GtkD GUI.
///
/// Scopes: Read (all reads), Manage (configuration: services, clients,
/// queues, subscriptions, webhooks, channels, bindings, PurgeQueue,
/// DeliverWebhook), Publish (PublishEvent), Consume (ConsumeMessages,
/// deleting = acknowledging QueueMessages).
module uim.platform.events.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.events;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.eventmesh";

ODataServiceModel eventsModel() {
  auto m = new ODataServiceModel(odataNamespace, "EventMeshService", "Event Mesh");

  m.entitySet("MessagingServices", "MessagingService")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("namespace", Edm.string_, "Namespace", false)
    .property("status", Edm.string_, "Status")
    .property("plan", Edm.string_, "Plan")
    .property("region", Edm.string_, "Region")
    .property("maxConnections", Edm.int32, "Max. Clients")
    .property("maxQueues", Edm.int32, "Max. Queues")
    .property("maxQueueDepth", Edm.int32, "Max. Queue Depth")
    .property("maxMessageSize", Edm.int64, "Max. Message Size (bytes)")
    .property("tokenEndpoint", Edm.string_, "Token Endpoint")
    .property("messagingEndpoint", Edm.string_, "Messaging Endpoint")
    .property("clientCount", Edm.int32, "Clients")
    .property("queueCount", Edm.int32, "Queues")
    .property("channelCount", Edm.int32, "Channels")
    .computed("clientCount", "queueCount", "channelCount")
    .immutableProps("namespace")
    .writable()
    .titled("Messaging Service", "Messaging Services", "name", "namespace")
    .columns("name", "namespace", "status", "plan", "queueCount", "clientCount")
    .filters("name", "status", "plan", "region")
    .scopes("Read", "Manage");

  m.entitySet("MessageClients", "MessageClient")
    .tenantAware()
    .property("serviceId", Edm.string_, "Messaging Service", false)
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("protocol", Edm.string_, "Protocol")
    .property("clientId", Edm.string_, "OAuth Client ID")
    .property("clientSecret", Edm.string_, "Client Secret")
    .property("hasSecret", Edm.boolean, "Has Secret")
    .property("tokenUrl", Edm.string_, "Token URL")
    .property("permittedNamespace", Edm.string_, "Permitted Namespace")
    .property("bindingCount", Edm.int32, "Bindings")
    .computed("hasSecret", "bindingCount")
    .immutableProps("serviceId", "clientId")
    .writable()
    .titled("Message Client", "Message Clients", "name", "clientId")
    .columns("name", "protocol", "status", "permittedNamespace", "bindingCount")
    .filters("serviceId", "status", "protocol")
    .scopes("Read", "Manage");

  m.entitySet("Queues", "Queue")
    .tenantAware()
    .property("serviceId", Edm.string_, "Messaging Service", false)
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("accessType", Edm.string_, "Access Type")
    .property("maxDepth", Edm.int32, "Max. Depth")
    .property("maxMessageSize", Edm.int64, "Max. Message Size (bytes)")
    .property("messageTtlSeconds", Edm.int64, "Message TTL (s)")
    .property("maxRedeliveryCount", Edm.int32, "Max. Redeliveries")
    .property("deadLetterQueueId", Edm.string_, "Dead Letter Queue")
    .property("ingressEnabled", Edm.boolean, "Ingress")
    .property("egressEnabled", Edm.boolean, "Egress")
    .property("owner", Edm.string_, "Owner")
    .property("messageCount", Edm.int32, "Messages")
    .property("subscriptionCount", Edm.int32, "Subscriptions")
    .property("webhookCount", Edm.int32, "Webhooks")
    .computed("messageCount", "subscriptionCount", "webhookCount")
    .immutableProps("serviceId", "name")
    .writable()
    .titled("Queue", "Queues", "name", "description")
    .columns("name", "status", "accessType", "messageCount", "subscriptionCount", "deadLetterQueueId")
    .filters("serviceId", "status", "accessType")
    .scopes("Read", "Manage");

  m.entitySet("QueueSubscriptions", "QueueSubscription")
    .tenantAware()
    .property("queueId", Edm.string_, "Queue", false)
    .property("serviceId", Edm.string_, "Messaging Service")
    .property("name", Edm.string_, "Name")
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("topicPattern", Edm.string_, "Topic Pattern", false)
    .computed("serviceId")
    .immutableProps("queueId")
    .writable()
    .titled("Queue Subscription", "Queue Subscriptions", "topicPattern", "queueId")
    .columns("topicPattern", "queueId", "status")
    .filters("queueId", "serviceId", "status")
    .scopes("Read", "Manage");

  m.entitySet("Webhooks", "Webhook")
    .tenantAware()
    .property("queueId", Edm.string_, "Queue", false)
    .property("serviceId", Edm.string_, "Messaging Service")
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("url", Edm.string_, "Endpoint URL", false)
    .property("headers", Edm.string_, "Headers (JSON)")
    .property("exemptHandshake", Edm.boolean, "Exempt Handshake")
    .property("authenticationType", Edm.string_, "Authentication")
    .property("credentials", Edm.string_, "Credentials")
    .property("hasCredentials", Edm.boolean, "Has Credentials")
    .property("tokenUrl", Edm.string_, "Token URL")
    .property("clientId", Edm.string_, "OAuth Client ID")
    .property("deliveryMode", Edm.string_, "Delivery Mode")
    .property("batchSize", Edm.int32, "Batch Size")
    .property("deliveredCount", Edm.int64, "Delivered")
    .property("failedCount", Edm.int64, "Failed")
    .property("lastDeliveryAt", Edm.dateTimeOffset, "Last Delivery")
    .property("lastError", Edm.string_, "Last Error")
    .computed("serviceId", "hasCredentials", "deliveredCount", "failedCount", "lastDeliveryAt", "lastError")
    .immutableProps("queueId")
    .writable()
    .titled("Webhook", "Webhooks", "name", "url")
    .columns("name", "url", "status", "deliveryMode", "deliveredCount", "failedCount", "lastError")
    .filters("queueId", "status", "authenticationType")
    .scopes("Read", "Manage");

  m.entitySet("EventChannels", "EventChannel")
    .tenantAware()
    .property("serviceId", Edm.string_, "Messaging Service", false)
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("channelType", Edm.string_, "Type")
    .property("topicName", Edm.string_, "Topic", false)
    .property("asyncapiDefinition", Edm.string_, "AsyncAPI Definition")
    .property("retentionHours", Edm.int32, "Retention (h)")
    .property("partitions", Edm.int32, "Partitions")
    .property("bindingCount", Edm.int32, "Bindings")
    .computed("bindingCount")
    .immutableProps("serviceId", "topicName")
    .writable()
    .titled("Event Channel", "Event Channels", "name", "topicName")
    .columns("name", "topicName", "channelType", "status", "bindingCount")
    .filters("serviceId", "status", "channelType")
    .scopes("Read", "Manage");

  m.entitySet("MessageBindings", "MessageBinding")
    .tenantAware()
    .property("clientId", Edm.string_, "Message Client", false)
    .property("serviceId", Edm.string_, "Messaging Service")
    .property("queueId", Edm.string_, "Queue")
    .property("channelId", Edm.string_, "Event Channel")
    .property("name", Edm.string_, "Name")
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("permission", Edm.string_, "Permission")
    .computed("serviceId")
    .immutableProps("clientId", "queueId", "channelId")
    .writable()
    .titled("Message Binding", "Message Bindings", "name", "permission")
    .columns("name", "clientId", "queueId", "channelId", "permission", "status")
    .filters("clientId", "queueId", "channelId", "permission")
    .scopes("Read", "Manage");

  m.entitySet("QueueMessages", "QueueMessage")
    .tenantAware()
    .property("queueId", Edm.string_, "Queue")
    .property("serviceId", Edm.string_, "Messaging Service")
    .property("correlationId", Edm.string_, "Message ID")
    .property("topic", Edm.string_, "Topic")
    .property("payload", Edm.string_, "Payload")
    .property("contentType", Edm.string_, "Content Type")
    .property("state", Edm.string_, "State")
    .property("size", Edm.int64, "Size (bytes)")
    .property("deliveryCount", Edm.int32, "Failed Deliveries")
    .property("expiresAt", Edm.dateTimeOffset, "Expires At")
    .property("publisherId", Edm.string_, "Publisher")
    .property("originalQueueId", Edm.string_, "Original Queue")
    .property("lastError", Edm.string_, "Last Error")
    .computed("queueId", "serviceId", "correlationId", "topic", "payload", "contentType", "state", "size",
      "deliveryCount", "expiresAt", "publisherId", "originalQueueId", "lastError")
    .writable(false, false, true) // DELETE = acknowledge
    .titled("Message", "Messages", "topic", "correlationId")
    .columns("topic", "queueId", "state", "size", "deliveryCount", "createdAt")
    .filters("queueId", "topic", "state")
    .scopes("Read", "Consume");

  m.singletonSet("Statistics", "Statistic")
    .property("tenantId", Edm.string_, "Tenant")
    .property("services", Edm.int32, "Messaging Services")
    .property("activeServices", Edm.int32, "Active Services")
    .property("clients", Edm.int32, "Clients")
    .property("queues", Edm.int32, "Queues")
    .property("subscriptions", Edm.int32, "Subscriptions")
    .property("webhooks", Edm.int32, "Webhooks")
    .property("failingWebhooks", Edm.int32, "Failing Webhooks")
    .property("channels", Edm.int32, "Channels")
    .property("bindings", Edm.int32, "Bindings")
    .property("queuedMessages", Edm.int32, "Queued Messages")
    .property("deadLetteredMessages", Edm.int32, "Dead Lettered Messages")
    .property("deliveredMessages", Edm.int64, "Delivered by Webhooks")
    .titled("Statistics", "Statistics")
    .scopes("Read", "");

  auto publish = m.complexType("PublishResult")
    .property("messageId", Edm.string_, "Message ID")
    .property("topic", Edm.string_, "Topic")
    .property("delivered", Edm.int32, "Queues");
  publish.properties ~= ODataPropertyDef("queueIds", Edm.string_, true, true, "Queues");
  publish.properties ~= ODataPropertyDef("rejectedQueueIds", Edm.string_, true, true, "Rejected Queues");

  m.complexType("DeliveryResult")
    .property("webhookId", Edm.string_, "Webhook")
    .property("webhookName", Edm.string_, "Name")
    .property("attempted", Edm.int32, "Attempted")
    .property("delivered", Edm.int32, "Delivered")
    .property("retried", Edm.int32, "Retried")
    .property("deadLettered", Edm.int32, "Dead Lettered")
    .property("discarded", Edm.int32, "Discarded")
    .property("lastError", Edm.string_, "Last Error");

  m.complexType("PurgeResult")
    .property("queueId", Edm.string_, "Queue")
    .property("removed", Edm.int32, "Removed");

  m.action("PublishEvent", "PublishResult")
    .parameter("topic", Edm.string_, false)
    .parameter("payload", Edm.string_, false)
    .parameter("serviceId", Edm.string_)
    .parameter("clientId", Edm.string_)
    .parameter("contentType", Edm.string_)
    .labelled("Publish Event")
    .requires("Publish");

  auto consume = m.action("ConsumeMessages", "QueueMessage")
    .parameter("queueId", Edm.string_, false)
    .parameter("clientId", Edm.string_)
    .parameter("maxMessages", Edm.int32)
    .labelled("Consume Messages")
    .requires("Consume");
  consume.returnsCollection = true;

  m.action("PurgeQueue", "PurgeResult")
    .parameter("queueId", Edm.string_, false)
    .labelled("Purge Queue")
    .requires("Manage");

  m.action("DeliverWebhook", "DeliveryResult")
    .parameter("webhookId", Edm.string_, false)
    .labelled("Deliver Webhook Now")
    .requires("Manage");

  m.validate();
  return m;
}

///
unittest {
  auto m = eventsModel();
  assert(m.has("Queues") && m.find("Statistics").singleton);
  assert(m.findAction("ConsumeMessages").returnEdmType == "Collection(uim.eventmesh.QueueMessage)");
  assert(m.find("QueueMessages").deletable && !m.find("QueueMessages").insertable);
}
