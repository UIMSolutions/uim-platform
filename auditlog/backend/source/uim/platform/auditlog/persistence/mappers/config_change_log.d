/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.config_change_log;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct ConfigChangeLogMapper {
  static Json toRecord(const ConfigChangeLog e) {
    auto r = baseRecord(e);
    r["auditLogId"] = e.auditLogId.value;
    r["changedBy"] = e.changedBy.value;
    r["configType"] = e.configType;
    r["configObjectId"] = e.configObjectId;
    r["changes"] = attributesToJson(e.changes);
    r["reason"] = e.reason;
    r["timestamp"] = e.timestamp;
    return r;
  }

  static ConfigChangeLog fromRecord(Json r) {
    ConfigChangeLog e;
    readBase(e, r);
    e.auditLogId = AuditLogId(fieldString(r, "auditLogId"));
    e.changedBy = UserId(fieldString(r, "changedBy"));
    e.configType = fieldString(r, "configType");
    e.configObjectId = fieldString(r, "configObjectId");
    e.changes = attributesFromJson(r, "changes");
    e.reason = fieldString(r, "reason");
    e.timestamp = fieldLong(r, "timestamp");
    return e;
  }
}
