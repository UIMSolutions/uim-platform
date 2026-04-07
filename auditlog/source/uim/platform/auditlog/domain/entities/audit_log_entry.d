/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.audit_log_entry;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Core audit log record — an immutable chronological entry.
@safe:
struct AuditLogEntry {
  AuditLogId id; // message_uuid
  TenantId tenantId;
  UserId userId;
  string userName;
  ServiceId serviceId; // app_or_service_id
  string serviceName;
  AuditCategory category;
  AuditSeverity severity = AuditSeverity.info;
  AuditAction action;
  AuditOutcome outcome = AuditOutcome.success;
  string objectType; // e.g. "user", "policy", "config"
  string objectId;
  string message;
  AuditAttribute[] attributes; // changed / accessed attributes
  string ipAddress;
  string userAgent;
  string correlationId; // trace across services
  string originApp; // originating application
  long timestamp; // stdTime
  string formatVersion = "1.0";

  Json toJson() const {
    return Json([
      "id": id,
      "tenantId": tenantId,
      "userId": userId,
      "userName": userName,
      "serviceId": serviceId,
      "serviceName": serviceName,
      "category": category.to!string,
      "severity": severity.to!string,
      "action": action.to!string,
      "outcome": outcome.to!string,
      "objectType": objectType,
      "objectId": objectId,
      "message": message,
      "attributes": attributes.map!(a => Json([
        "name": a.name,
        "oldValue": a.oldValue,
        "newValue": a.newValue
      ])).array,
      "ipAddress": ipAddress,
      "userAgent": userAgent,
      "correlationId": correlationId,
      "originApp": originApp,
      "timestamp": timestamp,
      "formatVersion": formatVersion
    ]);
  }
}

/// Key/value pair describing a changed or accessed attribute.
@safe:
struct AuditAttribute {
  string name;
  string oldValue;
  string newValue;

  Json toJson() const {
    return Json([
      "name": name,
      "oldValue": oldValue,
      "newValue": newValue
    ]);
  }
}
