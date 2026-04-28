/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.config_change_log;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Tracks security-critical configuration changes.
@safe:
struct ConfigChangeLog {
  mixin TenantEntity!(ConfigChangeLogId);

  AuditLogId auditLogId; // link to parent audit log entry
  UserId changedBy;
  string configType; // e.g., "security_policy", "idp_settings", "role_mapping"
  string configObjectId;
  AuditAttribute[] changes; // old/new value pairs
  string reason; // change justification
  long timestamp;

  Json toJson() const {
    return entityToJson()
      .set("changedBy", changedBy.toString)
      .set("configType", configType)
      .set("configObjectId", configObjectId)
      .set("changes", changes.map!(c => c.toJson()).array.toJson)
      .set("reason", reason)
      .set("timestamp", timestamp);
  }
}
