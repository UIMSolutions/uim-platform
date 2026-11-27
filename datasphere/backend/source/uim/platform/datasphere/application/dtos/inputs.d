/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T). Members
/// ending in "_" are sent under their API name.
module uim.platform.datasphere.application.dtos.inputs;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct SpaceInput {
  string name;
  string description;
  int priority = 5;
  double diskQuotaGiB = 10;
  double memoryQuotaGiB = 2;
  bool auditLogEnabled;
}

struct MemberInput {
  string spaceId;
  string userName;
  string displayName;
  string role = "viewer";
}

struct ConnectionInput {
  string spaceId;
  string name;
  string description;
  string connectionType = "hana";
  string host;
  int port;
  string database;
  string user;
  string password; /// write-only; "" on update keeps the stored password
  string[] properties;
}

struct RemoteTableInput {
  string spaceId;
  string connectionId;
  string name;
  string businessName;
  string description;
  string remoteSchema;
  string remoteObject;
  string replicationMode = "remote";
  string[] columns;
}

struct ViewInput {
  string spaceId;
  string name;
  string businessName;
  string description;
  string semantic = "relationalDataset";
  string sqlExpression;
  string[] columns;
  bool exposed;
}

struct DataFlowInput {
  string spaceId;
  string name;
  string businessName;
  string description;
  string[] sourceObjects;
  string[] transforms;
  string targetTable;
  string loadMode = "append";
}

struct TaskInput {
  string spaceId;
  string name;
  string description;
  string taskType = "replication";
  string targetObjectId;
  string frequency = "manual";
  int intervalMinutes;
  string startAt; /// ISO 8601; "" = from now
  int maxRetries = 1;
}

struct TaskChainInput {
  string spaceId;
  string name;
  string description;
  string[] taskIds;
  string failurePolicy = "stop";
  string frequency = "manual";
  int intervalMinutes;
  string startAt;
}

struct AccessControlInput {
  string spaceId;
  string name;
  string description;
  string criteriaColumn;
  string criteriaOperator = "equals";
  string[] criteriaValues;
  string[] targetViewIds;
  string[] assignedUsers;
  bool enabled = true;
}

struct CatalogAssetInput {
  string spaceId;
  string name;
  string businessName;
  string description;
  string assetType = "view";
  string sourceObjectId;
  string owner;
  string qualityStatus = "unknown";
  string sensitivity = "internal";
  string[] tags;
  string[] glossaryTerms;
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
