/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T). Members
/// ending in "_" are sent under their API name ("version_" → "version").
module uim.platform.ai_launchpad.application.dtos.inputs;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct WorkspaceInput {
  string name;
  string description;
  string status = "active";
}

struct ConnectionInput {
  string workspaceId;
  string name;
  string description;
  string connectionType = "aiCore";
  string url;
  string authUrl;
  string clientId;
  string clientSecret; /// write-only; "" on update keeps the stored secret
  string defaultResourceGroup = "default";
}

struct ResourceGroupInput {
  string connectionId;
  string description;
  string[] labels;
  string status = "ready";
}

struct ScenarioInput {
  string connectionId;
  string name;
  string description;
  string[] executables;
  string[] labels;
}

struct ConfigurationInput {
  string scenarioId;
  string name;
  string executableId;
  string[] parameters;
  string[] inputArtifacts;
}

struct ExecutionInput {
  string configurationId;
  string resourceGroupId; /// "" = the default resource group of the connection
}

struct DeploymentInput {
  string configurationId;
  string resourceGroupId; /// "" = the default resource group of the connection
  int minReplicas = 1;
  int maxReplicas = 1;
  int ttlMinutes;
}

struct ModelInput {
  string scenarioId;
  string executionId;
  string name;
  string version_ = "1";
  string description;
  string url;
  double sizeMiB = 0;
  string status = "available";
  string[] labels;
}

struct DatasetInput {
  string scenarioId;
  string name;
  string description;
  string url;
  double sizeMiB = 0;
  string status = "available";
  string[] labels;
}

struct PromptCollectionInput {
  string workspaceId;
  string name;
  string description;
}

struct PromptInput {
  string collectionId;
  string name;
  string description;
  string modelName = "gpt-4o-mini";
  string modelVersion = "latest";
  string systemMessage;
  string userMessage;
  double temperature = 0.7;
  int maxTokens = 256;
  double topP = 1.0;
  string status = "draft";
}

struct TileInput {
  string title;
  string subtitle;
  string info;
  string icon = "sap-icon://product";
  string groupName = "General";
  int sortOrder = 100;
  string targetType = "app";
  string target;
  string kpi;
  string kpiUnit;
  string requiredScope;
  bool visible = true;
}

struct RoleInput {
  string name;
  string description;
  string[] scopes;
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
