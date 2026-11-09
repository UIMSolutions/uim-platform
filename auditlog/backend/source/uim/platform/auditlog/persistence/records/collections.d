/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.records.collections;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the audit log service.
enum AuditCollections : string {
  auditLogs = "audit_logs",
  securityEvents = "security_events",
  dataAccessLogs = "data_access_logs",
  configChangeLogs = "config_change_logs",
  retentionPolicies = "retention_policies",
  auditConfigs = "audit_configs",
  exportJobs = "export_jobs",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int auditRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", auditRecordSchemaVersion)
      .set("collection", collection)
      .set("records", arr);
  }

  static SnapshotEnvelope fromJson(string collection, Json json) {
    SnapshotEnvelope env;
    env.collection = collection;
    if (json.type == Json.Type.object && "records" in json && json["records"].type == Json.Type.array)
      foreach (r; json["records"].get!(Json[]))
        env.records ~= r;
    return env;
  }
}
