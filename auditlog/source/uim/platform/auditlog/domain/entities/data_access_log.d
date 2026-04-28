/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.data_access_log;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Tracks read-access to sensitive / personal data.
@safe:
struct DataAccessLog {
  mixin TenantEntity!(DataAccessLogId);

  AuditLogId auditLogId; // link to parent audit log entry
  UserId accessedBy;
  string dataSubject; // person whose data was accessed
  string dataObjectType; // e.g., "user_profile", "payment_info"
  string dataObjectId;
  string[] accessedFields; // specific fields read
  string purpose; // business justification
  string channel; // API, UI, batch, etc.
  long timestamp;

  Json toJson() const {
    return entityToJson()
      .set("accessedBy", accessedBy)
      .set("dataSubject", dataSubject)
      .set("dataObjectType", dataObjectType)
      .set("dataObjectId", dataObjectId)
      .set("accessedFields", accessedFields.toJson)
      .set("purpose", purpose)
      .set("channel", channel)
      .set("timestamp", timestamp);
  }
}
