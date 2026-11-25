/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T). Members
/// ending in "_" (D keywords) have the API name without it ("version").
module uim.platform.integration_automation.application.dtos.inputs;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct SystemInput {
  string name;
  string description;
  string systemType = "sapS4HanaCloud";
  string host;
  int port = 443;
  string protocol = "https";
  string client;
  string sid;
  string environment = "production";
  string region;
}

struct DestinationInput {
  string name;
  string description;
  string systemId;
  string destinationType = "http";
  string url;
  string authentication = "noAuthentication";
  string proxyType = "internet";
  string locationId;
  string user;
  string tokenServiceUrl;
  string audience;
  string scope_;
  bool enabled = true;
}

struct ScenarioInput {
  string name;
  string description;
  string category = "custom";
  string version_ = "1.0";
  string sourceSystemType = "any";
  string targetSystemType = "any";
  string[] prerequisites;
}

struct ScenarioTaskInput {
  string scenarioId;
  int sequenceNumber = 10;
  string name;
  string description;
  string taskType = "manual";
  string priority = "medium";
  string assignedRole;
  string instructions;
  string destinationId;
  string automationEndpoint;
  string automationPayload;
  bool requiresSourceSystem;
  bool requiresTargetSystem;
  bool afterPrevious = true;
  string[] dependsOn;
  int estimatedMinutes = 15;
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
