/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, counts, health) are passed in by the
/// engine, which computes them once per request.
module uim.platform.application_events.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// ISO 8601 date-time (seconds, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional values and references).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

// ── landscape ─────────────────────────────────────────────────────────────

Json formationRow(const Formation f, long systems, long subscriptions) {
  auto j = auditRow(f);
  j["name"] = f.name;
  j["description"] = f.description;
  j["globalAccountId"] = f.globalAccountId;
  j["status"] = cast(string) f.status;
  j["systemCount"] = systems;
  j["subscriptionCount"] = subscriptions;
  return j;
}

struct SystemFacts {
  string formationName;
  long channels;
  long subscriptions;
  long lastEventAt;
}

Json systemRow(const SystemRegistration s, const SystemFacts f) {
  auto j = auditRow(s);
  j["name"] = s.name;
  j["description"] = s.description;
  j["systemType"] = cast(string) s.systemType;
  j["systemUrl"] = s.systemUrl;
  j["formationId"] = textOrNull(s.formationId.value);
  j["formationName"] = f.formationName;
  j["status"] = cast(string) s.status;
  j["channelCount"] = f.channels;
  j["subscriptionCount"] = f.subscriptions;
  j["lastEventAt"] = isoTime(f.lastEventAt);
  return j;
}

// ── catalog ───────────────────────────────────────────────────────────────

struct TopicFacts {
  string ownerName;
  long subscriptions;
  long messages;
  long lastPublishedAt;
}

Json topicRow(const EventTopic t, const TopicFacts f) {
  auto j = auditRow(t);
  j["eventType"] = t.eventType;
  j["title"] = t.title;
  j["description"] = t.description;
  j["category"] = t.category;
  j["version"] = t.version_;
  j["ownerSystemId"] = textOrNull(t.ownerSystemId.value);
  j["ownerSystemName"] = f.ownerName;
  j["status"] = cast(string) t.status;
  j["subscriptionCount"] = f.subscriptions;
  j["messageCount"] = f.messages;
  j["lastPublishedAt"] = isoTime(f.lastPublishedAt);
  return j;
}

/// Message counters of a channel or subscription.
struct MessageCounts {
  long total;
  long open;
  long queued;
  long retrying;
  long delivered;
  long deadLetters; /// open dead letters

  void add(const EventMessage m) {
    total++;
    if (m.isOpen)
      open++;
    if (m.status == MessageStatus.queued)
      queued++;
    if (m.status == MessageStatus.retrying)
      retrying++;
    if (m.status == MessageStatus.delivered)
      delivered++;
  }
}

Json channelRow(const EventChannel c, string consumerName, long subscriptions, const MessageCounts n) {
  auto j = auditRow(c);
  j["name"] = c.name;
  j["description"] = c.description;
  j["channelType"] = cast(string) c.channelType;
  j["endpoint"] = c.endpoint;
  j["consumerSystemId"] = c.consumerSystemId.value;
  j["consumerSystemName"] = consumerName;
  j["deliveryMode"] = cast(string) c.deliveryMode;
  j["maxSizeBytes"] = c.maxSizeBytes;
  j["status"] = cast(string) c.status;
  j["subscriptionCount"] = subscriptions;
  j["openCount"] = n.open;
  j["queuedCount"] = n.queued;
  j["deliveredCount"] = n.delivered;
  return j;
}

// ── subscriptions ─────────────────────────────────────────────────────────

struct SubscriptionFacts {
  string producerName;
  string consumerName;
  string channelName;
  string channelType;
  string formationName;
  long filters;
  MessageCounts messages;
}

/// "error" with open dead letters, "warning" with retries or while paused, else "ok".
string subscriptionHealth(const EventSubscription s, const MessageCounts n) {
  if (n.deadLetters > 0)
    return "error";
  if (n.retrying > 0 || !s.isActive)
    return "warning";
  return "ok";
}

Json subscriptionRow(const EventSubscription s, const SubscriptionFacts f) {
  auto j = auditRow(s);
  j["name"] = s.name;
  j["description"] = s.description;
  j["producerSystemId"] = s.producerSystemId.value;
  j["producerSystemName"] = f.producerName;
  j["consumerSystemId"] = s.consumerSystemId.value;
  j["consumerSystemName"] = f.consumerName;
  j["eventType"] = s.eventType;
  j["channelId"] = s.channelId.value;
  j["channelName"] = f.channelName;
  j["channelType"] = f.channelType;
  j["formationId"] = textOrNull(s.formationId.value);
  j["formationName"] = f.formationName;
  j["status"] = cast(string) s.status;
  j["maxRetries"] = s.maxRetries;
  j["retryBackoffSeconds"] = s.retryBackoffSeconds;
  j["filterCount"] = f.filters;
  j["messageCount"] = f.messages.total;
  j["deliveredCount"] = f.messages.delivered;
  j["openCount"] = f.messages.open;
  j["deadLetterCount"] = f.messages.deadLetters;
  j["health"] = subscriptionHealth(s, f.messages);
  j["lastMatchedAt"] = isoTime(s.lastMatchedAt);
  return j;
}

Json filterRow(const EventFilter f, string subscriptionName) {
  auto j = auditRow(f);
  j["subscriptionId"] = f.subscriptionId.value;
  j["subscriptionName"] = subscriptionName;
  j["filterType"] = cast(string) f.filterType;
  j["attribute"] = f.attribute;
  j["operator"] = cast(string) f.operator_;
  j["value"] = f.value;
  j["active"] = f.active;
  j["description"] = f.description;
  j["summary"] = f.summary;
  return j;
}

// ── delivery ──────────────────────────────────────────────────────────────

Json messageRow(const EventMessage m, string subscriptionName, string channelName) {
  auto j = auditRow(m);
  j["subscriptionId"] = m.subscriptionId.value;
  j["subscriptionName"] = subscriptionName;
  j["channelId"] = m.channelId.value;
  j["channelName"] = channelName;
  j["producerSystemId"] = m.producerSystemId.value;
  j["consumerSystemId"] = m.consumerSystemId.value;
  j["eventId"] = m.eventId;
  j["eventType"] = m.eventType;
  j["subject"] = m.subject;
  j["payload"] = m.payload;
  j["contentType"] = m.contentType;
  j["eventTime"] = isoTime(m.eventTime);
  j["sizeBytes"] = m.sizeBytes;
  j["status"] = cast(string) m.status;
  j["attempts"] = m.attempts;
  j["maxAttempts"] = m.maxAttempts;
  j["nextAttemptAt"] = m.status == MessageStatus.retrying ? isoTime(m.nextAttemptAt) : Json(null);
  j["lastAttemptAt"] = isoTime(m.lastAttemptAt);
  j["lastError"] = m.lastError;
  j["deliveredAt"] = isoTime(m.deliveredAt);
  return j;
}

Json deadLetterRow(const DeadLetterEntry d, string subscriptionName, string channelName, string payload) {
  auto j = auditRow(d);
  j["messageId"] = d.messageId.value;
  j["subscriptionId"] = d.subscriptionId.value;
  j["subscriptionName"] = subscriptionName;
  j["channelId"] = d.channelId.value;
  j["channelName"] = channelName;
  j["eventId"] = d.eventId;
  j["eventType"] = d.eventType;
  j["reason"] = d.reason;
  j["attempts"] = d.attempts;
  j["status"] = cast(string) d.status;
  j["resolvedAt"] = isoTime(d.resolvedAt);
  j["resolvedBy"] = d.resolvedBy;
  j["payload"] = payload;
  return j;
}

Json userRow(const UserAccount u, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["password"] = Json(null);
  j["scopes"] = texts(u.scopes);
  j["scopesText"] = u.scopes.join(", ");
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json statisticsRow(const AehStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!AehStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

// ── results ───────────────────────────────────────────────────────────────

/// "name: routed (delivered)" / "name: filtered — reason", one per line.
string outcomeLines(const PublishResult r) {
  string[] lines;
  foreach (o; r.outcomes) {
    auto name = o.subscriptionName.length ? o.subscriptionName : o.subscriptionId.value;
    if (o.routed)
      lines ~= name ~ ": " ~ cast(string) o.status ~ (o.reason.length ? " — " ~ o.reason : "");
    else
      lines ~= name ~ ": not routed — " ~ o.reason;
  }
  return lines.join("\n");
}

Json publishRow(const PublishResult r) {
  auto j = Json.emptyObject;
  j["eventId"] = r.eventId;
  j["eventType"] = r.eventType;
  j["source"] = r.source;
  j["duplicate"] = r.duplicate;
  j["preview"] = r.preview;
  j["candidates"] = r.candidates;
  j["routed"] = r.routed;
  j["filtered"] = r.filtered;
  j["skipped"] = r.skipped;
  j["delivered"] = r.delivered;
  j["queued"] = r.queued;
  j["retrying"] = r.retrying;
  j["deadLettered"] = r.deadLettered;
  j["summary"] = r.summary;
  j["outcomes"] = outcomeLines(r);
  j["notes"] = r.notes.join("\n");
  return j;
}

/// The publish result with the outcomes as objects (REST).
Json publishDetailRow(const PublishResult r) {
  auto j = publishRow(r);
  auto list = Json.emptyArray;
  foreach (o; r.outcomes) {
    auto x = Json.emptyObject;
    x["subscriptionId"] = o.subscriptionId.value;
    x["subscriptionName"] = o.subscriptionName;
    x["routed"] = o.routed;
    x["messageId"] = textOrNull(o.messageId.value);
    x["status"] = o.routed ? Json(cast(string) o.status) : Json(null);
    x["reason"] = o.reason;
    list ~= x;
  }
  j["outcomes"] = list;
  j["notes"] = texts(r.notes);
  return j;
}

Json deliveryRow(const DeliveryResult r) {
  auto j = Json.emptyObject;
  j["messageId"] = r.messageId.value;
  j["subscriptionName"] = r.subscriptionName;
  j["channelName"] = r.channelName;
  j["status"] = cast(string) r.status;
  j["attempts"] = r.attempts;
  j["nextAttemptAt"] = r.status == MessageStatus.retrying ? isoTime(r.nextAttemptAt) : Json(null);
  j["statusCode"] = r.statusCode;
  j["message"] = r.message;
  j["deadLetterId"] = textOrNull(r.deadLetterId.value);
  return j;
}

Json dispatchRow(const DispatchSummary s) {
  auto j = Json.emptyObject;
  j["due"] = s.due;
  j["attempted"] = s.attempted;
  j["delivered"] = s.delivered;
  j["queued"] = s.queued;
  j["retrying"] = s.retrying;
  j["deadLettered"] = s.deadLettered;
  j["dropped"] = s.dropped;
  j["waiting"] = s.waiting;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json purgeRow(const PurgeResult r) {
  return Json(["messages": Json(r.messages), "deadLetters": Json(r.deadLetters)]);
}

Json seedRow(const SeedResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

///
unittest {
  EventSubscription s;
  MessageCounts n;
  assert(subscriptionHealth(s, n) == "ok");
  n.retrying = 1;
  assert(subscriptionHealth(s, n) == "warning");
  n.deadLetters = 1;
  assert(subscriptionHealth(s, n) == "error");
  PublishResult r;
  RouteOutcome a;
  a.subscriptionName = "bp";
  a.routed = true;
  a.status = MessageStatus.delivered;
  RouteOutcome b;
  b.subscriptionName = "hr";
  b.reason = "subscription is paused";
  r.outcomes = [a, b];
  assert(outcomeLines(r) == "bp: delivered\nhr: not routed — subscription is paused", outcomeLines(r));
  assert(publishDetailRow(r)["outcomes"].length == 2);
  EventMessage m;
  m.status = MessageStatus.delivered;
  m.nextAttemptAt = 5;
  assert(messageRow(m, "", "")["nextAttemptAt"].type == Json.Type.null_);
}
