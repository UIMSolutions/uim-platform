/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.dtos.auditlogentry;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
// ──────────────── Audit Log Entry DTOs ────────────────

struct WriteAuditLogRequest {
  TenantId tenantId;
  UserId userId;
  string userName;
  ServiceId serviceId;
  string serviceName;
  AuditCategory category;
  AuditSeverity severity;
  AuditAction action;
  AuditOutcome outcome;
  string objectType;
  string objectId;
  string message;
  AuditAttribute[] attributes;
  string ipAddress;
  string userAgent;
  string correlationId;
  string originApp;
}

@safe:
struct AuditLogQueryRequest {
  TenantId tenantId;
  AuditCategory[] categories;
  long timeFrom;
  long timeTo;
  int limit = 500; // SAP default page size
  int offset;
}






