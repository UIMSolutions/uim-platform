/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.data_access_log;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct DataAccessLogMapper {
  static Json toRecord(const DataAccessLog e) {
    auto r = baseRecord(e);
    r["auditLogId"] = e.auditLogId.value;
    r["accessedBy"] = e.accessedBy.value;
    r["dataSubject"] = e.dataSubject;
    r["dataObjectType"] = e.dataObjectType;
    r["dataObjectId"] = e.dataObjectId;
    r["accessedFields"] = stringsToJson(e.accessedFields);
    r["purpose"] = e.purpose;
    r["channel"] = e.channel;
    r["timestamp"] = e.timestamp;
    return r;
  }

  static DataAccessLog fromRecord(Json r) {
    DataAccessLog e;
    readBase(e, r);
    e.auditLogId = AuditLogId(fieldString(r, "auditLogId"));
    e.accessedBy = UserId(fieldString(r, "accessedBy"));
    e.dataSubject = fieldString(r, "dataSubject");
    e.dataObjectType = fieldString(r, "dataObjectType");
    e.dataObjectId = fieldString(r, "dataObjectId");
    e.accessedFields = fieldStrings(r, "accessedFields");
    e.purpose = fieldString(r, "purpose");
    e.channel = fieldString(r, "channel");
    e.timestamp = fieldLong(r, "timestamp");
    return e;
  }
}
