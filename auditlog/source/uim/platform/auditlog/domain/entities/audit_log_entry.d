module uim.platform.auditlog.domain.entities.audit_log_entry;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Core audit log record — an immutable chronological entry.
@safe:
struct AuditLogEntry
{
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
}

/// Key/value pair describing a changed or accessed attribute.
@safe:
struct AuditAttribute
{
  string name;
  string oldValue;
  string newValue;
}
