/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.security_event;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct SecurityEventMapper {
  static Json toRecord(const SecurityEvent e) {
    auto r = baseRecord(e);
    r["auditLogId"] = e.auditLogId.value;
    r["userId"] = e.userId.value;
    r["userName"] = e.userName;
    r["eventType"] = e.eventType;
    r["ipAddress"] = e.ipAddress;
    r["userAgent"] = e.userAgent;
    r["clientId"] = e.clientId;
    r["identityProvider"] = e.identityProvider;
    r["authMethod"] = e.authMethod;
    r["outcome"] = e.outcome.to!string;
    r["failureReason"] = e.failureReason;
    r["riskLevel"] = e.riskLevel;
    r["timestamp"] = e.timestamp;
    return r;
  }

  static SecurityEvent fromRecord(Json r) {
    SecurityEvent e;
    readBase(e, r);
    e.auditLogId = AuditLogId(fieldString(r, "auditLogId"));
    e.userId = UserId(fieldString(r, "userId"));
    e.userName = fieldString(r, "userName");
    e.eventType = fieldString(r, "eventType");
    e.ipAddress = fieldString(r, "ipAddress");
    e.userAgent = fieldString(r, "userAgent");
    e.clientId = fieldString(r, "clientId");
    e.identityProvider = fieldString(r, "identityProvider");
    e.authMethod = fieldString(r, "authMethod");
    e.outcome = fieldEnum!AuditOutcome(r, "outcome", AuditOutcome.success);
    e.failureReason = fieldString(r, "failureReason");
    e.riskLevel = fieldString(r, "riskLevel");
    e.timestamp = fieldLong(r, "timestamp");
    return e;
  }
}
