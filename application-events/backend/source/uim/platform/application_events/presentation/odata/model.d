/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads, routing preview), Publish (events), Operate
/// (delivery, dead letters, pause / resume), Manage (landscape, catalog,
/// channels, subscriptions, filters), Admin (Users). Timestamps are
/// Edm.DateTimeOffset.
module uim.platform.application_events.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.appevents";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

ODataServiceModel eventHubModel() {
  auto m = new ODataServiceModel(odataNamespace, "EventHubService", "Application Event Hub");

  // ── landscape ───────────────────────────────────────────────────────────
  audited(m.entitySet("Formations", "Formation")
      .property("id", Edm.string_, "Formation", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("globalAccountId", Edm.string_, "Global Account")
      .property("status", Edm.string_, "Status")
      .property("systemCount", Edm.int32, "Systems")
      .property("subscriptionCount", Edm.int32, "Subscriptions")
      .computed("status", "systemCount", "subscriptionCount"))
    .writable()
    .titled("Formation", "Formations", "name", "description")
    .columns("name", "status", "systemCount", "subscriptionCount", "globalAccountId")
    .filters("status")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Systems", "System")
      .property("id", Edm.string_, "System", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("systemType", Edm.string_, "Role")
      .property("systemUrl", Edm.string_, "URL")
      .property("formationId", Edm.string_, "Formation")
      .property("formationName", Edm.string_, "Formation Name")
      .property("status", Edm.string_, "Status")
      .property("channelCount", Edm.int32, "Channels")
      .property("subscriptionCount", Edm.int32, "Subscriptions")
      .property("lastEventAt", Edm.dateTimeOffset, "Last Event")
      .computed("formationName", "status", "channelCount", "subscriptionCount", "lastEventAt"))
    .writable()
    .titled("System", "Systems", "name", "systemType")
    .columns("name", "systemType", "formationName", "status", "subscriptionCount", "lastEventAt")
    .filters("systemType", "status", "formationId")
    .scopes(readScope, manageScope);

  // ── catalog and channels ────────────────────────────────────────────────
  audited(m.entitySet("EventTypes", "EventType")
      .property("id", Edm.string_, "Event Type", false)
      .property("eventType", Edm.string_, "Type", false)
      .property("title", Edm.string_, "Title")
      .property("description", Edm.string_, "Description")
      .property("category", Edm.string_, "Category")
      .property("version", Edm.string_, "Version")
      .property("ownerSystemId", Edm.string_, "Owner")
      .property("ownerSystemName", Edm.string_, "Owner Name")
      .property("status", Edm.string_, "Status")
      .property("subscriptionCount", Edm.int32, "Subscriptions")
      .property("messageCount", Edm.int32, "Messages")
      .property("lastPublishedAt", Edm.dateTimeOffset, "Last Published")
      .computed("ownerSystemName", "status", "subscriptionCount", "messageCount", "lastPublishedAt")
      .immutableProps("eventType"))
    .writable()
    .titled("Event Type", "Event Catalog", "title", "eventType")
    .columns("title", "eventType", "category", "version", "status", "subscriptionCount")
    .filters("status", "category", "ownerSystemId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Channels", "Channel")
      .property("id", Edm.string_, "Channel", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("channelType", Edm.string_, "Type")
      .property("endpoint", Edm.string_, "Endpoint")
      .property("consumerSystemId", Edm.string_, "Consumer", false)
      .property("consumerSystemName", Edm.string_, "Consumer Name")
      .property("deliveryMode", Edm.string_, "Delivery")
      .property("maxSizeBytes", Edm.int64, "Max. Size (bytes)")
      .property("status", Edm.string_, "Status")
      .property("subscriptionCount", Edm.int32, "Subscriptions")
      .property("openCount", Edm.int32, "Open Messages")
      .property("queuedCount", Edm.int32, "Queued")
      .property("deliveredCount", Edm.int32, "Delivered")
      .computed("consumerSystemName", "status", "subscriptionCount", "openCount", "queuedCount", "deliveredCount")
      .immutableProps("channelType", "consumerSystemId"))
    .writable()
    .titled("Channel", "Channels", "name", "endpoint")
    .columns("name", "channelType", "consumerSystemName", "deliveryMode", "status", "openCount")
    .filters("channelType", "status", "consumerSystemId", "deliveryMode")
    .scopes(readScope, manageScope);

  // ── subscriptions and filters ───────────────────────────────────────────
  audited(m.entitySet("Subscriptions", "Subscription")
      .property("id", Edm.string_, "Subscription", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("producerSystemId", Edm.string_, "Producer", false)
      .property("producerSystemName", Edm.string_, "Producer Name")
      .property("consumerSystemId", Edm.string_, "Consumer", false)
      .property("consumerSystemName", Edm.string_, "Consumer Name")
      .property("eventType", Edm.string_, "Event Type", false)
      .property("channelId", Edm.string_, "Channel", false)
      .property("channelName", Edm.string_, "Channel Name")
      .property("channelType", Edm.string_, "Channel Type")
      .property("formationId", Edm.string_, "Formation")
      .property("formationName", Edm.string_, "Formation Name")
      .property("status", Edm.string_, "Status")
      .property("maxRetries", Edm.int32, "Max. Retries")
      .property("retryBackoffSeconds", Edm.int32, "Back-off (s)")
      .property("filterCount", Edm.int32, "Filters")
      .property("messageCount", Edm.int32, "Messages")
      .property("deliveredCount", Edm.int32, "Delivered")
      .property("openCount", Edm.int32, "Open")
      .property("deadLetterCount", Edm.int32, "Open Dead Letters")
      .property("health", Edm.string_, "Health")
      .property("lastMatchedAt", Edm.dateTimeOffset, "Last Event")
      .computed("producerSystemName", "consumerSystemName", "channelName", "channelType", "formationId", "formationName",
        "status", "filterCount", "messageCount", "deliveredCount", "openCount", "deadLetterCount", "health", "lastMatchedAt")
      .immutableProps("producerSystemId", "consumerSystemId"))
    .writable()
    .titled("Subscription", "Subscriptions", "name", "eventType")
    .columns("name", "producerSystemName", "consumerSystemName", "eventType", "status", "health", "deliveredCount")
    .filters("status", "producerSystemId", "consumerSystemId", "channelId", "health")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Filters", "Filter")
      .property("id", Edm.string_, "Filter", false)
      .property("subscriptionId", Edm.string_, "Subscription", false)
      .property("subscriptionName", Edm.string_, "Subscription Name")
      .property("filterType", Edm.string_, "Type")
      .property("attribute", Edm.string_, "Attribute", false)
      .property("operator", Edm.string_, "Operator")
      .property("value", Edm.string_, "Value")
      .property("active", Edm.boolean, "Active")
      .property("description", Edm.string_, "Description")
      .property("summary", Edm.string_, "Filter")
      .computed("subscriptionName", "summary")
      .immutableProps("subscriptionId"))
    .writable()
    .titled("Filter", "Filters", "summary", "subscriptionName")
    .columns("summary", "filterType", "active", "description")
    .filters("subscriptionId", "filterType", "active")
    .scopes(readScope, manageScope);

  // ── delivery ────────────────────────────────────────────────────────────
  audited(m.entitySet("Messages", "Message")
      .property("id", Edm.string_, "Message", false)
      .property("subscriptionId", Edm.string_, "Subscription")
      .property("subscriptionName", Edm.string_, "Subscription Name")
      .property("channelId", Edm.string_, "Channel")
      .property("channelName", Edm.string_, "Channel Name")
      .property("producerSystemId", Edm.string_, "Source")
      .property("consumerSystemId", Edm.string_, "Consumer")
      .property("eventId", Edm.string_, "Event ID")
      .property("eventType", Edm.string_, "Event Type")
      .property("subject", Edm.string_, "Subject")
      .property("payload", Edm.string_, "Payload")
      .property("contentType", Edm.string_, "Content Type")
      .property("eventTime", Edm.dateTimeOffset, "Event Time")
      .property("sizeBytes", Edm.int64, "Size (bytes)")
      .property("status", Edm.string_, "Status")
      .property("attempts", Edm.int32, "Attempts")
      .property("maxAttempts", Edm.int32, "Max. Attempts")
      .property("nextAttemptAt", Edm.dateTimeOffset, "Next Attempt")
      .property("lastAttemptAt", Edm.dateTimeOffset, "Last Attempt")
      .property("lastError", Edm.string_, "Last Error")
      .property("deliveredAt", Edm.dateTimeOffset, "Delivered At"))
    .writable(false, false, false)
    .titled("Message", "Messages", "eventType", "subscriptionName")
    .columns("createdAt", "eventType", "subscriptionName", "status", "attempts", "deliveredAt")
    .filters("status", "subscriptionId", "channelId", "producerSystemId", "eventType", "eventId")
    .scopes(readScope, operateScope);

  audited(m.entitySet("DeadLetters", "DeadLetter")
      .property("id", Edm.string_, "Dead Letter", false)
      .property("messageId", Edm.string_, "Message")
      .property("subscriptionId", Edm.string_, "Subscription")
      .property("subscriptionName", Edm.string_, "Subscription Name")
      .property("channelId", Edm.string_, "Channel")
      .property("channelName", Edm.string_, "Channel Name")
      .property("eventId", Edm.string_, "Event ID")
      .property("eventType", Edm.string_, "Event Type")
      .property("reason", Edm.string_, "Reason")
      .property("attempts", Edm.int32, "Attempts")
      .property("status", Edm.string_, "Status")
      .property("resolvedAt", Edm.dateTimeOffset, "Resolved At")
      .property("resolvedBy", Edm.string_, "Resolved By")
      .property("payload", Edm.string_, "Payload"))
    .writable(false, false, false)
    .titled("Dead Letter", "Dead Letters", "eventType", "reason")
    .columns("createdAt", "eventType", "subscriptionName", "reason", "attempts", "status")
    .filters("status", "subscriptionId", "channelId", "eventType")
    .scopes(readScope, operateScope);

  // ── built-in login ──────────────────────────────────────────────────────
  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password")
      .collection("scopes", Edm.string_, "Scopes")
      .property("scopesText", Edm.string_, "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopesText", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  // ── statistics ──────────────────────────────────────────────────────────
  auto stats = m.singletonSet("Statistics", "Statistic").keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false);
  foreach (name; statisticNames)
    stats.property(name, Edm.int32, statisticLabel(name));
  stats.titled("Statistics", "Statistics", "tenantId").scopes(readScope, manageScope);

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("PublishResult")
    .property("eventId", Edm.string_, "Event ID")
    .property("eventType", Edm.string_, "Event Type")
    .property("source", Edm.string_, "Source")
    .property("duplicate", Edm.boolean, "Duplicate")
    .property("preview", Edm.boolean, "Preview")
    .property("candidates", Edm.int32, "Candidates")
    .property("routed", Edm.int32, "Routed")
    .property("filtered", Edm.int32, "Filtered")
    .property("skipped", Edm.int32, "Skipped")
    .property("delivered", Edm.int32, "Delivered")
    .property("queued", Edm.int32, "Queued")
    .property("retrying", Edm.int32, "Retrying")
    .property("deadLettered", Edm.int32, "Dead Letters")
    .property("summary", Edm.string_, "Summary")
    .property("outcomes", Edm.string_, "Subscriptions")
    .property("notes", Edm.string_, "Notes");
  m.complexType("DeliveryResult")
    .property("messageId", Edm.string_, "Message")
    .property("subscriptionName", Edm.string_, "Subscription")
    .property("channelName", Edm.string_, "Channel")
    .property("status", Edm.string_, "Status")
    .property("attempts", Edm.int32, "Attempts")
    .property("nextAttemptAt", Edm.dateTimeOffset, "Next Attempt")
    .property("statusCode", Edm.int32, "HTTP Status")
    .property("message", Edm.string_, "Message")
    .property("deadLetterId", Edm.string_, "Dead Letter");
  m.complexType("DispatchSummary")
    .property("due", Edm.int32, "Due")
    .property("attempted", Edm.int32, "Attempted")
    .property("delivered", Edm.int32, "Delivered")
    .property("queued", Edm.int32, "Queued")
    .property("retrying", Edm.int32, "Retrying")
    .property("deadLettered", Edm.int32, "Dead Letters")
    .property("dropped", Edm.int32, "Dropped")
    .property("waiting", Edm.int32, "Waiting")
    .property("messages", Edm.string_, "Messages");
  m.complexType("PurgeResult")
    .property("messages", Edm.int32, "Messages")
    .property("deadLetters", Edm.int32, "Dead Letters");
  m.complexType("SeedResult")
    .property("formations", Edm.int32)
    .property("systems", Edm.int32)
    .property("topics", Edm.int32)
    .property("channels", Edm.int32)
    .property("subscriptions", Edm.int32)
    .property("filters", Edm.int32)
    .property("events", Edm.int32)
    .property("messages", Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  void eventParameters(ODataActionDef a) {
    a.parameter("type", Edm.string_, false).parameter("source", Edm.string_, false).parameter("subject", Edm.string_)
      .parameter("id", Edm.string_).parameter("time", Edm.string_).parameter("data", Edm.string_);
  }

  auto publish = m.action("PublishEvent", "PublishResult").labelled("Publish Event").requires(publishScope);
  eventParameters(publish);
  auto preview = m.action("PreviewRouting", "PublishResult").labelled("Preview Routing").requires(readScope);
  eventParameters(preview);
  m.action("DispatchDue", "DispatchSummary").labelled("Deliver Due Messages").requires(operateScope);
  m.action("DeliverMessage", "DeliveryResult").parameter("id", Edm.string_, false).labelled("Deliver Now")
    .requires(operateScope);
  m.action("AcknowledgeMessage", "Message").parameter("id", Edm.string_, false).labelled("Acknowledge")
    .requires(operateScope);
  m.action("RequeueDeadLetter", "DeliveryResult").parameter("id", Edm.string_, false).labelled("Requeue")
    .requires(operateScope);
  m.action("RequeueDeadLetters", "DispatchSummary").parameter("subscriptionId", Edm.string_)
    .labelled("Requeue All Open Dead Letters").requires(operateScope);
  m.action("DiscardDeadLetter", "DeadLetter").parameter("id", Edm.string_, false).labelled("Discard")
    .requires(operateScope);
  m.action("PauseSubscription", "Subscription").parameter("id", Edm.string_, false).labelled("Pause").requires(operateScope);
  m.action("ResumeSubscription", "Subscription").parameter("id", Edm.string_, false).labelled("Resume")
    .requires(operateScope);
  m.action("SetChannelStatus", "Channel").parameter("id", Edm.string_, false).parameter("status", Edm.string_, false)
    .labelled("Set Channel Status").requires(manageScope);
  m.action("SetEventTypeStatus", "EventType").parameter("id", Edm.string_, false).parameter("status", Edm.string_, false)
    .labelled("Set Event Type Status").requires(manageScope);
  m.action("SetSystemStatus", "System").parameter("id", Edm.string_, false).parameter("status", Edm.string_, false)
    .labelled("Set System Status").requires(manageScope);
  m.action("SetFormationStatus", "Formation").parameter("id", Edm.string_, false).parameter("status", Edm.string_, false)
    .labelled("Set Formation Status").requires(manageScope);
  m.action("AssignSystem", "System").parameter("id", Edm.string_, false).parameter("systemId", Edm.string_, false)
    .labelled("Assign System").requires(manageScope);
  m.action("UnassignSystem", "System").parameter("systemId", Edm.string_, false).labelled("Remove From Formation")
    .requires(manageScope);
  m.action("PurgeMessages", "PurgeResult").labelled("Purge Finished Messages").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Landscape").requires(manageScope);
  return m;
}

/// Numeric members of the Statistics singleton (all of AehStatistics but the tenant).
enum string[] statisticNames = [
    "formations", "systems", "producers", "consumers", "topics", "activeTopics", "channels", "activeChannels",
    "subscriptions", "activeSubscriptions", "filters", "messages", "openMessages", "retryingMessages",
    "queuedMessages", "eventsLast24h", "deliveredLast24h", "deadLetters", "openDeadLetters", "users"
  ];

/// "deliveredLast24h" → "Delivered (24 h)"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string label;
  foreach (i, dchar c; name) {
    if (i == 0)
      label ~= toUpper(c);
    else {
      if (isUpper(c))
        label ~= ' ';
      label ~= c;
    }
  }
  return label.replace(" Last24h", " (24 h)").replace("Last24h", " (24 h)");
}

///
unittest {
  import std.traits : FieldNameTuple;

  auto m = eventHubModel();
  m.validate();
  assert(m.has("Subscriptions") && m.find("Statistics").singleton && m.find("Filters").key == "id");
  assert(!m.find("Messages").insertable && !m.find("DeadLetters").updatable);
  assert(m.find("Channels").propertyOf("channelType").immutable_ && m.find("Subscriptions").propertyOf("health").computed);
  assert(m.findAction("DispatchDue").returnEdmType == "uim.appevents.DispatchSummary");
  assert(statisticLabel("deliveredLast24h") == "Delivered (24 h)", statisticLabel("deliveredLast24h"));
  // the statistics model and the port agree
  string[] fields;
  static foreach (name; FieldNameTuple!AehStatistics)
    static if (name != "tenantId")
      fields ~= name;
  assert(fields == statisticNames, fields.to!string);
}
