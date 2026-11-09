/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.dtos.statistics;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Aggregated audit figures of one tenant.
struct AuditStatistics {
  TenantId tenantId;
  size_t totalEntries;
  size_t[string] byCategory; /// key: AuditCategory member name
  size_t[string] bySeverity; /// key: AuditSeverity member name
  size_t[string] byOutcome; /// key: AuditOutcome member name
  size_t securityEvents;
  size_t failedLogins;
  size_t dataAccessLogs;
  size_t configChanges;
  size_t retentionPolicies;
  size_t exportJobs;
  int retentionDays;
  long lastEntryAt;

  Json toJson() const {
    Json counts(const size_t[string] map) {
      auto j = Json.emptyObject;
      foreach (k, v; map)
        j[k] = Json(v);
      return j;
    }

    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("totalEntries", totalEntries)
      .set("byCategory", counts(byCategory))
      .set("bySeverity", counts(bySeverity))
      .set("byOutcome", counts(byOutcome))
      .set("securityEvents", securityEvents)
      .set("failedLogins", failedLogins)
      .set("dataAccessLogs", dataAccessLogs)
      .set("configChanges", configChanges)
      .set("retentionPolicies", retentionPolicies)
      .set("exportJobs", exportJobs)
      .set("retentionDays", retentionDays)
      .set("lastEntryAt", lastEntryAt);
  }
}
