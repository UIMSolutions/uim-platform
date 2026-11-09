/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.audit_log_entry;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct AuditLogEntryMapper {
  static Json toRecord(const AuditLogEntry e) {
    auto r = baseRecord(e);
    r["userId"] = e.userId.value;
    r["userName"] = e.userName;
    r["serviceId"] = e.serviceId.value;
    r["serviceName"] = e.serviceName;
    r["category"] = e.category.to!string;
    r["severity"] = e.severity.to!string;
    r["action"] = cast(string) e.action;
    r["outcome"] = e.outcome.to!string;
    r["objectType"] = e.objectType;
    r["objectId"] = e.objectId;
    r["message"] = e.message;
    r["attributes"] = attributesToJson(e.attributes);
    r["ipAddress"] = e.ipAddress;
    r["userAgent"] = e.userAgent;
    r["correlationId"] = e.correlationId;
    r["originApp"] = e.originApp;
    r["timestamp"] = e.timestamp;
    r["formatVersion"] = e.formatVersion;
    return r;
  }

  static AuditLogEntry fromRecord(Json r) {
    AuditLogEntry e;
    readBase(e, r);
    e.userId = UserId(fieldString(r, "userId"));
    e.userName = fieldString(r, "userName");
    e.serviceId = ServiceId(fieldString(r, "serviceId"));
    e.serviceName = fieldString(r, "serviceName");
    e.category = fieldEnum!AuditCategory(r, "category", AuditCategory.securityEvents);
    e.severity = fieldEnum!AuditSeverity(r, "severity", AuditSeverity.info);
    e.action = fieldString(r, "action").toAuditAction;
    e.outcome = fieldEnum!AuditOutcome(r, "outcome", AuditOutcome.success);
    e.objectType = fieldString(r, "objectType");
    e.objectId = fieldString(r, "objectId");
    e.message = fieldString(r, "message");
    e.attributes = attributesFromJson(r, "attributes");
    e.ipAddress = fieldString(r, "ipAddress");
    e.userAgent = fieldString(r, "userAgent");
    e.correlationId = fieldString(r, "correlationId");
    e.originApp = fieldString(r, "originApp");
    e.timestamp = fieldLong(r, "timestamp");
    e.formatVersion = fieldString(r, "formatVersion", "1.0");
    return e;
  }
}
///
unittest {
  mixin(ShowTest!("AuditLogEntryMapper"));

  auto e = AuditLogEntry(TenantId("t1"));
  e.category = AuditCategory.dataModification;
  e.severity = AuditSeverity.critical;
  e.action = AuditAction.delete_;
  e.message = "deleted";
  e.attributes = [AuditAttribute("name", "a", "b")];
  e.timestamp = 42;

  auto back = AuditLogEntryMapper.fromRecord(AuditLogEntryMapper.toRecord(e));
  assert(back.id == e.id);
  assert(back.tenantId == e.tenantId);
  assert(back.category == AuditCategory.dataModification);
  assert(back.severity == AuditSeverity.critical);
  assert(back.action == AuditAction.delete_);
  assert(back.attributes.length == 1 && back.attributes[0].newValue == "b");
  assert(back.timestamp == 42);
}
