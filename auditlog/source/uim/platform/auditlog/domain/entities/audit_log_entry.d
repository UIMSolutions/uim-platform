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
    auto attrs = attributes.map!(a => Json.emptyObject
        .set("name", a.name)
        .set("oldValue", a.oldValue)
        .set("newValue", a.newValue)
    ).array.toJson;

    return Json.emptyObject
      .set("id", id.toString)
      .set("tenantId", tenantId.toString)
      .set("userId", userId.toString)
      .set("userName", userName)
      .set("serviceId", serviceId.toString)
      .set("serviceName", serviceName)
      .set("category", category.to!string)
      .set("severity", severity.to!string)
      .set("action", action.to!string)
      .set("outcome", outcome.to!string)
      .set("objectType", objectType)
      .set("objectId", objectId)
      .set("message", message)
      .set("attributes", attrs)
      .set("ipAddress", ipAddress)
      .set("userAgent", userAgent)
      .set("correlationId", correlationId)
      .set("originApp", originApp)
      .set("timestamp", timestamp)
      .set("formatVersion", formatVersion);
  }
}

/// Key/value pair describing a changed or accessed attribute.
@safe:
struct AuditAttribute {
  string name;
  string oldValue;
  string newValue;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("oldValue", oldValue)
      .set("newValue", newValue);
  }
}
