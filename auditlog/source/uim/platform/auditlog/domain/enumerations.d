module uim.platform.auditlog.domain.enumerations;
import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
/// Predefined SAP audit event categories.
enum AuditCategory {
  securityEvents, // audit.security-events
  configuration, // audit.configuration
  dataAccess, // audit.data-access
  dataModification, // audit.data-modification
}

AuditCategory toAuditCategory(string s) {
  switch (s) {
  case "audit.security-events", "securityEvents":
    return AuditCategory.securityEvents;
  case "audit.configuration", "configuration":
    return AuditCategory.configuration;
  case "audit.data-access", "dataAccess":
    return AuditCategory.dataAccess;
  case "audit.data-modification", "dataModification":
    return AuditCategory.dataModification;
  default:
    return AuditCategory.securityEvents;
  }
}

/// Severity / log level of an audit event.
enum AuditSeverity {
  info,
  warning,
  error,
  critical,
}

/// Concrete action that triggered the audit entry.
enum AuditAction {
  create,
  read_,
  update,
  delete_,
  login,
  logout,
  loginFailed,
  passwordChange,
  roleAssign,
  roleRevoke,
  policyChange,
  configChange,
  export_,
  dataAccess,
  consentChange,
  tokenIssue,
  tokenRevoke,
  mfaEnroll,
  mfaVerify,
}

/// Outcome of the audited operation.
enum AuditOutcome {
  success,
  failure,
  denied,
  error,
}

/// Retention policy status.
enum RetentionStatus {
  active,
  inactive,
  expired,
}

/// Export job status.
enum ExportStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Export output format.
enum ExportFormat {
  json,
  csv,
}

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}
