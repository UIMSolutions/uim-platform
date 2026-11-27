/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, counts) are passed in by the engine,
/// which computes them once per request. Secrets (connection passwords,
/// password hashes) are never part of a row.
module uim.platform.datasphere.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum double bytesPerMiB = 1024.0 * 1024.0;

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

/// Bytes → MiB / GiB with two decimals.
double mib(long bytes) {
  return roundTo2(bytes / bytesPerMiB);
}

double gib(long bytes) {
  return roundTo2(cast(double) bytes / bytesPerGiB);
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

private Json scopedRow(E)(const E e, string spaceName) {
  auto j = auditRow(e);
  j["spaceId"] = e.spaceId.value;
  j["spaceName"] = spaceName;
  return j;
}

// ── spaces ────────────────────────────────────────────────────────────────

Json spaceRow(const Space s, long members, long objects) {
  auto j = auditRow(s);
  j["name"] = s.name;
  j["description"] = s.description;
  j["status"] = cast(string) s.status;
  j["priority"] = s.priority;
  j["diskQuotaGiB"] = gib(s.diskQuotaBytes);
  j["memoryQuotaGiB"] = gib(s.memoryQuotaBytes);
  j["usedDiskGiB"] = gib(s.usedDiskBytes);
  j["diskUsagePercent"] = roundTo2(s.diskUsagePercent);
  j["auditLogEnabled"] = s.auditLogEnabled;
  j["lockedReason"] = s.lockedReason;
  j["memberCount"] = members;
  j["objectCount"] = objects;
  return j;
}

Json memberRow(const SpaceMember m, string spaceName) {
  auto j = scopedRow(m, spaceName);
  j["userName"] = m.userName;
  j["displayName"] = m.displayName;
  j["role"] = cast(string) m.role;
  return j;
}

// ── data integration ──────────────────────────────────────────────────────

Json connectionRow(const Connection c, string spaceName, long remoteTables) {
  auto j = scopedRow(c, spaceName);
  j["name"] = c.name;
  j["description"] = c.description;
  j["connectionType"] = cast(string) c.connectionType;
  j["host"] = c.host;
  j["port"] = c.port;
  j["database"] = c.database;
  j["user"] = c.user;
  j["password"] = Json(null); // write-only
  j["properties"] = texts(c.properties);
  j["endpoint"] = c.endpoint;
  j["hasPassword"] = c.password.length > 0;
  j["status"] = cast(string) c.status;
  j["statusMessage"] = c.statusMessage;
  j["lastValidatedAt"] = isoTime(c.lastValidatedAt);
  j["remoteTableCount"] = remoteTables;
  return j;
}

Json remoteTableRow(const RemoteTable t, string spaceName, string connectionName) {
  auto j = scopedRow(t, spaceName);
  j["connectionId"] = t.connectionId.value;
  j["connectionName"] = connectionName;
  j["name"] = t.name;
  j["businessName"] = t.businessName;
  j["description"] = t.description;
  j["remoteSchema"] = t.remoteSchema;
  j["remoteObject"] = t.remoteObject;
  j["replicationMode"] = cast(string) t.replicationMode;
  j["replicationStatus"] = cast(string) t.replicationStatus;
  j["columns"] = texts(t.columns);
  j["columnCount"] = t.columns.length;
  j["rowCount"] = t.rowCount;
  j["sizeMiB"] = mib(t.sizeBytes);
  j["lastReplicatedAt"] = isoTime(t.lastReplicatedAt);
  j["lastMessage"] = t.lastMessage;
  return j;
}

// ── modeling ──────────────────────────────────────────────────────────────

Json viewRow(const DataView v, string spaceName, long protectedBy) {
  auto j = scopedRow(v, spaceName);
  j["name"] = v.name;
  j["businessName"] = v.businessName;
  j["description"] = v.description;
  j["semantic"] = cast(string) v.semantic;
  j["sqlExpression"] = v.sqlExpression;
  j["sourceObjects"] = texts(v.sourceObjects);
  j["sourcesText"] = v.sourceObjects.join(", ");
  j["columns"] = texts(v.columns);
  j["columnCount"] = v.columns.length;
  j["exposed"] = v.exposed;
  j["deploymentStatus"] = cast(string) v.deploymentStatus;
  j["deployedAt"] = isoTime(v.deployedAt);
  j["persisted"] = v.persisted;
  j["rowCount"] = v.rowCount;
  j["persistedMiB"] = mib(v.persistedBytes);
  j["persistedAt"] = isoTime(v.persistedAt);
  j["lastRunStatus"] = cast(string) v.lastRunStatus;
  j["lastRunMessage"] = v.lastRunMessage;
  j["protectedBy"] = protectedBy;
  return j;
}

Json dataFlowRow(const DataFlow f, string spaceName) {
  auto j = scopedRow(f, spaceName);
  j["name"] = f.name;
  j["businessName"] = f.businessName;
  j["description"] = f.description;
  j["sourceObjects"] = texts(f.sourceObjects);
  j["sourcesText"] = f.sourceObjects.join(", ");
  j["transforms"] = texts(f.transforms);
  j["transformCount"] = f.transforms.length;
  j["targetTable"] = f.targetTable;
  j["loadMode"] = cast(string) f.loadMode;
  j["deploymentStatus"] = cast(string) f.deploymentStatus;
  j["deployedAt"] = isoTime(f.deployedAt);
  j["lastRunStatus"] = cast(string) f.lastRunStatus;
  j["lastRunAt"] = isoTime(f.lastRunAt);
  j["lastRunDurationMs"] = f.lastRunDurationMs;
  j["targetRows"] = f.targetRows;
  j["targetMiB"] = mib(f.targetBytes);
  j["lastRunMessage"] = f.lastRunMessage;
  return j;
}

// ── scheduling ────────────────────────────────────────────────────────────

private void scheduleColumns(E)(ref Json j, const E e) {
  j["frequency"] = cast(string) e.frequency;
  j["intervalMinutes"] = e.intervalMinutes;
  j["startAt"] = isoTime(e.startAt);
  j["schedule"] = scheduleText(e.frequency, e.intervalMinutes);
  j["status"] = cast(string) e.status;
  j["nextRunAt"] = isoTime(e.nextRunAt);
  j["lastRunStatus"] = cast(string) e.lastRunStatus;
  j["lastRunAt"] = isoTime(e.lastRunAt);
  j["lastRunDurationMs"] = e.lastRunDurationMs;
  j["lastRunMessage"] = e.lastRunMessage;
}

Json taskRow(const DataTask t, string spaceName, string targetName) {
  auto j = scopedRow(t, spaceName);
  j["name"] = t.name;
  j["description"] = t.description;
  j["taskType"] = cast(string) t.taskType;
  j["targetObjectId"] = t.targetObjectId;
  j["targetName"] = targetName;
  j["maxRetries"] = t.maxRetries;
  j["consecutiveFailures"] = t.consecutiveFailures;
  scheduleColumns(j, t);
  return j;
}

Json taskChainRow(const TaskChain c, string spaceName, const string[string] taskNames) {
  auto j = scopedRow(c, spaceName);
  j["name"] = c.name;
  j["description"] = c.description;
  j["taskIds"] = texts(c.taskIds);
  string[] steps;
  foreach (i, id; c.taskIds)
    steps ~= format("%d. %s", i + 1, taskNames.get(id, id));
  j["stepsText"] = steps.join(" → ");
  j["stepCount"] = c.taskIds.length;
  j["failurePolicy"] = cast(string) c.failurePolicy;
  scheduleColumns(j, c);
  return j;
}

Json runRow(const TaskRun r, string spaceName) {
  auto j = scopedRow(r, spaceName);
  j["objectType"] = cast(string) r.objectType;
  j["objectId"] = r.objectId;
  j["objectName"] = r.objectName;
  j["taskId"] = textOrNull(r.taskId);
  j["chainRunId"] = textOrNull(r.chainRunId);
  j["trigger"] = cast(string) r.trigger;
  j["status"] = cast(string) r.status;
  j["attempts"] = r.attempts;
  j["startedAt"] = isoTime(r.startedAt);
  j["finishedAt"] = isoTime(r.finishedAt);
  j["durationMs"] = r.durationMs;
  j["rowsProcessed"] = r.rowsProcessed;
  j["sizeMiB"] = mib(r.sizeBytes);
  j["message"] = r.message;
  return j;
}

// ── governance ────────────────────────────────────────────────────────────

/// "COUNTRY oneOf DE, AT, CH"
string criteriaText(const DataAccessControl d) {
  auto values = d.criteriaOperator == CriteriaOperator.between ? d.criteriaValues.join(" … ") : d.criteriaValues.join(", ");
  return d.criteriaColumn ~ " " ~ cast(string) d.criteriaOperator ~ " " ~ values;
}

Json accessControlRow(const DataAccessControl d, string spaceName, const string[string] viewNames) {
  auto j = scopedRow(d, spaceName);
  j["name"] = d.name;
  j["description"] = d.description;
  j["criteriaColumn"] = d.criteriaColumn;
  j["criteriaOperator"] = cast(string) d.criteriaOperator;
  j["criteriaValues"] = texts(d.criteriaValues);
  j["criteriaText"] = criteriaText(d);
  j["targetViewIds"] = texts(d.targetViewIds);
  j["viewsText"] = d.targetViewIds.map!(v => viewNames.get(v, v)).join(", ");
  j["assignedUsers"] = texts(d.assignedUsers);
  j["usersText"] = d.assignedUsers.join(", ");
  j["enabled"] = d.enabled;
  return j;
}

Json catalogRow(const CatalogAsset a, string spaceName) {
  auto j = scopedRow(a, spaceName);
  j["name"] = a.name;
  j["businessName"] = a.businessName;
  j["description"] = a.description;
  j["assetType"] = cast(string) a.assetType;
  j["sourceObjectId"] = textOrNull(a.sourceObjectId);
  j["owner"] = a.owner;
  j["qualityStatus"] = cast(string) a.qualityStatus;
  j["sensitivity"] = cast(string) a.sensitivity;
  j["tags"] = texts(a.tags);
  j["tagsText"] = a.tags.join(", ");
  j["glossaryTerms"] = texts(a.glossaryTerms);
  j["termsText"] = a.glossaryTerms.join(", ");
  j["accessCount"] = a.accessCount;
  j["lastAccessedAt"] = isoTime(a.lastAccessedAt);
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

Json statisticsRow(const DspStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!DspStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

// ── results ───────────────────────────────────────────────────────────────

Json accessDecisionRow(const AccessDecision d, string viewId, string user) {
  auto j = Json.emptyObject;
  j["viewId"] = viewId;
  j["user"] = user;
  j["allowed"] = d.allowed;
  j["protected"] = d.protected_;
  j["matchedControls"] = d.matchedControls.join(", ");
  j["reason"] = d.reason;
  return j;
}

Json schedulerRow(const SchedulerSummary s) {
  auto j = Json.emptyObject;
  j["due"] = s.due;
  j["started"] = s.started;
  j["completed"] = s.completed;
  j["failed"] = s.failed;
  j["skipped"] = s.skipped;
  j["summary"] = s.summary;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json purgeRow(const PurgeResult r) {
  return Json(["runs": Json(r.runs)]);
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
  c.password = "secret";
  auto row = connectionRow(c, "Sales", 0);
  assert(row["password"].type == Json.Type.null_ && row["hasPassword"].get!bool && !row.toString.canFind("secret"));
  DataAccessControl d;
  d.criteriaColumn = "AMOUNT";
  d.criteriaOperator = CriteriaOperator.between;
  d.criteriaValues = ["1", "9"];
  assert(criteriaText(d) == "AMOUNT between 1 … 9");
  TaskChain chain;
  chain.taskIds = ["a", "b"];
  assert(taskChainRow(chain, "", ["a": "Replicate"])["stepsText"].get!string == "1. Replicate → 2. b");
  assert(mib(1024 * 1024 * 3) == 3 && gib(bytesPerGiB / 2) == 0.5);
}
