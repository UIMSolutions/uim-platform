/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, counts) are passed in by the engine,
/// which computes them once per request. Secrets (client secrets, password
/// hashes) are never part of a row.
module uim.platform.ai_launchpad.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.ai_launchpad;

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

double roundTo2(double v) {
  import std.math : round;

  return round(v * 100) / 100;
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

private void list(ref Json j, string name, const string[] values, string separator = ", ") {
  j[name] = texts(values);
  j[name ~ "Text"] = values.join(separator);
}

// ── runtimes ──────────────────────────────────────────────────────────────

Json workspaceRow(const Workspace w, long connections, long collections) {
  auto j = auditRow(w);
  j["name"] = w.name;
  j["description"] = w.description;
  j["status"] = cast(string) w.status;
  j["connectionCount"] = connections;
  j["promptCollectionCount"] = collections;
  return j;
}

Json connectionRow(const Connection c, string workspaceName, long groups, long scenarios) {
  auto j = auditRow(c);
  j["workspaceId"] = c.workspaceId.value;
  j["workspaceName"] = workspaceName;
  j["name"] = c.name;
  j["description"] = c.description;
  j["connectionType"] = cast(string) c.connectionType;
  j["url"] = c.url;
  j["authUrl"] = c.authUrl;
  j["clientId"] = c.clientId;
  j["clientSecret"] = Json(null); // write-only
  j["hasSecret"] = c.hasSecret;
  j["defaultResourceGroup"] = c.defaultResourceGroup;
  j["status"] = cast(string) c.status;
  j["statusMessage"] = c.statusMessage;
  j["lastValidatedAt"] = isoTime(c.lastValidatedAt);
  j["resourceGroupCount"] = groups;
  j["scenarioCount"] = scenarios;
  return j;
}

Json resourceGroupRow(const ResourceGroup g, string connectionName, long executions, long deployments) {
  auto j = auditRow(g);
  j["connectionId"] = g.connectionId.value;
  j["connectionName"] = connectionName;
  j["description"] = g.description;
  list(j, "labels", g.labels);
  j["status"] = cast(string) g.status;
  j["activeExecutions"] = executions;
  j["activeDeployments"] = deployments;
  return j;
}

// ── ML life cycle ─────────────────────────────────────────────────────────

/// Counts of the resources referencing a scenario / configuration.
struct UsageCounts {
  long configurations;
  long executions;
  long deployments;
  long models;
  long datasets;
}

Json scenarioRow(const Scenario s, string connectionName, UsageCounts n) {
  auto j = auditRow(s);
  j["connectionId"] = s.connectionId.value;
  j["connectionName"] = connectionName;
  j["name"] = s.name;
  j["description"] = s.description;
  list(j, "executables", s.executables);
  list(j, "labels", s.labels);
  j["configurationCount"] = n.configurations;
  j["executionCount"] = n.executions;
  j["deploymentCount"] = n.deployments;
  j["modelCount"] = n.models;
  j["datasetCount"] = n.datasets;
  return j;
}

Json configurationRow(const Configuration c, string scenarioName, UsageCounts n) {
  auto j = auditRow(c);
  j["scenarioId"] = c.scenarioId.value;
  j["scenarioName"] = scenarioName;
  j["connectionId"] = c.connectionId.value;
  j["name"] = c.name;
  j["executableId"] = c.executableId;
  list(j, "parameters", c.parameters);
  list(j, "inputArtifacts", c.inputArtifacts);
  j["executionCount"] = n.executions;
  j["deploymentCount"] = n.deployments;
  j["inUse"] = n.executions + n.deployments > 0;
  return j;
}

Json executionRow(const Execution e, string configurationName, string scenarioName) {
  auto j = auditRow(e);
  j["configurationId"] = e.configurationId.value;
  j["configurationName"] = configurationName;
  j["scenarioId"] = e.scenarioId.value;
  j["scenarioName"] = scenarioName;
  j["connectionId"] = e.connectionId.value;
  j["resourceGroupId"] = e.resourceGroupId.value;
  j["status"] = cast(string) e.status;
  j["statusMessage"] = e.statusMessage;
  j["startedAt"] = isoTime(e.startedAt);
  j["completedAt"] = isoTime(e.completedAt);
  j["durationSeconds"] = e.durationSeconds;
  return j;
}

Json deploymentRow(const Deployment d, string configurationName, string scenarioName) {
  auto j = auditRow(d);
  j["configurationId"] = d.configurationId.value;
  j["configurationName"] = configurationName;
  j["scenarioId"] = d.scenarioId.value;
  j["scenarioName"] = scenarioName;
  j["connectionId"] = d.connectionId.value;
  j["resourceGroupId"] = d.resourceGroupId.value;
  j["status"] = cast(string) d.status;
  j["statusMessage"] = d.statusMessage;
  j["deploymentUrl"] = textOrNull(d.deploymentUrl);
  j["minReplicas"] = d.minReplicas;
  j["maxReplicas"] = d.maxReplicas;
  j["ttlMinutes"] = d.ttlMinutes;
  j["startedAt"] = isoTime(d.startedAt);
  j["stoppedAt"] = isoTime(d.stoppedAt);
  j["expiresAt"] = d.status == DeploymentStatus.running && d.ttlMinutes > 0 ? isoTime(plusMinutes(d.startedAt,
      d.ttlMinutes)) : Json(null);
  return j;
}

// ── registry ──────────────────────────────────────────────────────────────

Json modelRow(const Model m, string scenarioName) {
  auto j = auditRow(m);
  j["scenarioId"] = m.scenarioId.value;
  j["scenarioName"] = scenarioName;
  j["executionId"] = textOrNull(m.executionId);
  j["name"] = m.name;
  j["version"] = m.version_;
  j["description"] = m.description;
  j["url"] = m.url;
  j["sizeMiB"] = roundTo2(m.sizeMiB);
  j["status"] = cast(string) m.status;
  list(j, "labels", m.labels);
  return j;
}

Json datasetRow(const Dataset d, string scenarioName) {
  auto j = auditRow(d);
  j["scenarioId"] = d.scenarioId.value;
  j["scenarioName"] = scenarioName;
  j["name"] = d.name;
  j["description"] = d.description;
  j["url"] = d.url;
  j["sizeMiB"] = roundTo2(d.sizeMiB);
  j["status"] = cast(string) d.status;
  list(j, "labels", d.labels);
  return j;
}

// ── generative AI hub ─────────────────────────────────────────────────────

Json promptCollectionRow(const PromptCollection c, string workspaceName, long prompts) {
  auto j = auditRow(c);
  j["workspaceId"] = c.workspaceId.value;
  j["workspaceName"] = workspaceName;
  j["name"] = c.name;
  j["description"] = c.description;
  j["promptCount"] = prompts;
  return j;
}

Json promptRow(const Prompt p, string collectionName) {
  auto j = auditRow(p);
  j["collectionId"] = p.collectionId.value;
  j["collectionName"] = collectionName;
  j["name"] = p.name;
  j["description"] = p.description;
  j["modelName"] = p.modelName;
  j["modelVersion"] = p.modelVersion;
  j["systemMessage"] = p.systemMessage;
  j["userMessage"] = p.userMessage;
  j["temperature"] = roundTo2(p.temperature);
  j["maxTokens"] = p.maxTokens;
  j["topP"] = roundTo2(p.topP);
  j["status"] = cast(string) p.status;
  j["version"] = p.version_;
  list(j, "inputParams", p.inputParams);
  j["lastOutput"] = p.lastOutput;
  j["lastRunAt"] = isoTime(p.lastRunAt);
  j["runCount"] = p.runCount;
  return j;
}

Json promptRunRow(const PromptRunResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!PromptRunResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

// ── launchpad ─────────────────────────────────────────────────────────────

private Json tileFields(const Tile t, Json j) {
  j["title"] = t.title;
  j["subtitle"] = t.subtitle;
  j["info"] = t.info;
  j["icon"] = t.icon;
  j["groupName"] = t.groupName;
  j["sortOrder"] = t.sortOrder;
  j["targetType"] = cast(string) t.targetType;
  j["target"] = t.target;
  j["kpi"] = t.kpi;
  j["kpiUnit"] = t.kpiUnit;
  j["requiredScope"] = t.requiredScope;
  return j;
}

Json tileRow(const Tile t) {
  auto j = tileFields(t, auditRow(t));
  j["visible"] = t.visible;
  return j;
}

Json launchpadTileRow(const LaunchpadTile x) {
  auto j = Json.emptyObject;
  j["id"] = x.tile.id.value;
  tileFields(x.tile, j);
  j["kpiValue"] = x.hasKpi ? Json(x.kpiValue) : Json(null);
  return j;
}

// ── administration ────────────────────────────────────────────────────────

Json userRow(const UserAccount u, const string[] scopes, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["email"] = u.email;
  j["password"] = Json(null); // write-only
  list(j, "roles", u.roles);
  list(j, "scopes", scopes);
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json roleRow(const Role r, long users) {
  auto j = auditRow(r);
  j["name"] = r.name;
  j["description"] = r.description;
  list(j, "scopes", r.scopes);
  j["builtIn"] = r.builtIn;
  j["userCount"] = users;
  return j;
}

Json logEntryRow(const LogEntry e) {
  auto j = auditRow(e);
  j["category"] = cast(string) e.category;
  j["severity"] = cast(string) e.severity;
  j["eventType"] = e.eventType;
  j["subject"] = e.subject;
  j["actor"] = e.createdBy.value;
  j["message"] = e.message;
  j["details"] = e.details;
  return j;
}

Json statisticsRow(const AilpStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!AilpStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

// ── results ───────────────────────────────────────────────────────────────

Json reconcileRow(const ReconcileSummary s) {
  auto j = Json.emptyObject;
  j["checked"] = s.checked;
  j["started"] = s.started;
  j["completed"] = s.completed;
  j["failed"] = s.failed;
  j["deployed"] = s.deployed;
  j["dead"] = s.dead;
  j["expired"] = s.expired;
  j["summary"] = s.summary;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json purgeRow(const PurgeResult r) {
  return Json(["entries": Json(r.entries)]);
}

Json seedRow(const SeedResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

///
unittest {
  Connection c;
  c.clientSecret = "very secret";
  auto row = connectionRow(c, "ML", 0, 0);
  assert(row["clientSecret"].type == Json.Type.null_ && row["hasSecret"].get!bool && !row.toString.canFind("very secret"));
  UserAccount u;
  u.passwordHash = "pbkdf2-sha256$1$x$y";
  u.roles = ["Viewer"];
  auto ur = userRow(u, ["Read"], 0);
  assert(!ur.toString.canFind("pbkdf2") && ur["rolesText"].get!string == "Viewer" && ur["scopes"].length == 1);
  LaunchpadTile lt;
  lt.tile.id = TileId("x");
  assert(launchpadTileRow(lt)["kpiValue"].type == Json.Type.null_);
  lt.hasKpi = true;
  lt.kpiValue = 4;
  assert(launchpadTileRow(lt)["kpiValue"].get!long == 4);
}
