/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T). Members
/// ending in "_" are sent under their API name ("version_" → "version").
module uim.platform.application_events.application.dtos.inputs;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct FormationInput {
  string name;
  string description;
  string globalAccountId;
}

struct SystemInput {
  string name;
  string description;
  string systemType = "both";
  string systemUrl;
  string formationId; /// "" = not assigned
}

struct TopicInput {
  string eventType;
  string title;
  string description;
  string category;
  string version_ = "1.0.0";
  string ownerSystemId;
}

struct ChannelInput {
  string name;
  string description;
  string channelType = "webhook";
  string endpoint;
  string consumerSystemId;
  string deliveryMode = "atLeastOnce";
  long maxSizeBytes = 1_048_576;
}

struct SubscriptionInput {
  string name;
  string description;
  string producerSystemId;
  string consumerSystemId;
  string eventType;
  string channelId;
  int maxRetries = 5;
  int retryBackoffSeconds = 30;
}

struct FilterInput {
  string subscriptionId;
  string filterType = "include";
  string attribute;
  string operator_ = "equals";
  string value;
  bool active = true;
  string description;
}

/// Create a resource: an optional id ("" = generated) and the input.
struct CreateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput input;
}

/// Change a resource (PATCH semantics).
struct UpdateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput changes;
}

/// A create command with every member of the input set (tests, demo data).
CreateCommand!TInput createCommand(TInput)(TenantId t, UserId actor, string id, TInput input) {
  import std.traits : FieldNameTuple;

  CreateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.input.values = input;
  static foreach (name; FieldNameTuple!TInput)
    c.input.set(name);
  return c;
}

/// An update command changing the given members only.
UpdateCommand!TInput updateCommand(TInput)(TenantId t, UserId actor, string id, TInput values, string[] fields...) {
  UpdateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.changes.values = values;
  foreach (f; fields)
    c.changes.set(f);
  return c;
}

/// A CloudEvent sent by a producer (structured mode JSON).
struct PublishRequest {
  TenantId tenantId;
  UserId actor;
  Json event; /// {specversion, id, type, source, subject?, time?, datacontenttype?, data?}
}

/// A publish request from plain values (CLI, OData action, demo data).
PublishRequest publishRequest(TenantId t, UserId actor, string type, string source, Json data, string subject = "",
  string id = "") {
  auto e = Json.emptyObject;
  e["specversion"] = cloudEventsSpecVersion;
  e["type"] = type;
  e["source"] = source;
  if (subject.length)
    e["subject"] = subject;
  if (id.length)
    e["id"] = id;
  if (data.type != Json.Type.undefined && data.type != Json.Type.null_)
    e["data"] = data;
  return PublishRequest(t, actor, e);
}
