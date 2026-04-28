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
  mixin TenantEntity!(AuditLogId);

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

    return entityToJson
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

  static AuditLogEntry fromJson(Json json) {
    auto entry = AuditLogEntry();
    entry.id = json["id"].to!AuditLogId;
    entry.tenantId = json["tenantId"].to!TenantId;
    entry.userId = json["userId"].to!UserId;
    entry.userName = json.toString("userName");
    entry.serviceId = json["serviceId"].to!ServiceId;
    entry.serviceName = json.toString("serviceName");
    entry.category = json["category"].to!AuditCategory;
    entry.severity = json["severity"].to!AuditSeverity;
    entry.action = json["action"].to!AuditAction;
    entry.outcome = json["outcome"].to!AuditOutcome;
    entry.objectType = json.toString("objectType");
    entry.objectId = json.toString("objectId");
    entry.message = json.toString("message");
    // attributes parsing omitted for brevity
    entry.ipAddress = json.toString("ipAddress");
    entry.userAgent = json.toString("userAgent");
    entry.correlationId = json.toString("correlationId");
    entry.originApp = json.toString("originApp");
    entry.timestamp = json["timestamp"].to!long;
    return entry;
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
