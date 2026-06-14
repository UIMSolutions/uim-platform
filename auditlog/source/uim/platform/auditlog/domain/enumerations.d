module uim.platform.auditlog.domain.enumerations;
import uim.platform.auditlog;

// mixin(ShowModule!());
@safe:
/// Predefined SAP audit event categories.
enum AuditCategory {
  securityEvents, // audit.security-events
  configuration, // audit.configuration
  dataAccess, // audit.data-access
  dataModification, // audit.data-modification
}

AuditCategory toAuditCategory(string s) {
  const map = [
    "audit.security-events": AuditCategory.securityEvents,
    "audit.configuration": AuditCategory.configuration,
    "audit.data-access": AuditCategory.dataAccess,
    "audit.data-modification": AuditCategory.dataModification
  ];
  return map.get(s.toLower, AuditCategory.securityEvents);
}

private static string categoryToString(AuditCategory c) {
  final switch (c) {
  case AuditCategory.securityEvents:
    return "audit.security-events";
  case AuditCategory.configuration:
    return "audit.configuration";
  case AuditCategory.dataAccess:
    return "audit.data-access";
  case AuditCategory.dataModification:
    return "audit.data-modification";
  }
}
/// Severity / log level of an audit event.
enum AuditSeverity {
  info,
  warning,
  error,
  critical,
}
AuditSeverity toAuditSeverity(string s) {
  const map = [
    "info": AuditSeverity.info,
    "warning": AuditSeverity.warning,
    "error": AuditSeverity.error,
    "critical": AuditSeverity.critical
  ];
  return map.get(s.toLower, AuditSeverity.info);
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
AuditAction toAuditAction(string s) {
  const map = [
    "create": AuditAction.create,
    "read": AuditAction.read_,
    "update": AuditAction.update,
    "delete": AuditAction.delete_,
    "login": AuditAction.login,
    "logout": AuditAction.logout,
    "loginfailed": AuditAction.loginFailed,
    "passwordchange": AuditAction.passwordChange,
    "roleassign": AuditAction.roleAssign,
    "rolerevoke": AuditAction.roleRevoke,
    "policychange": AuditAction.policyChange,
    "configchange": AuditAction.configChange,
    "export": AuditAction.export_,
    "dataaccess": AuditAction.dataAccess,
    "consentchange": AuditAction.consentChange,
    "tokenissue": AuditAction.tokenIssue,
    "tokenrevoke": AuditAction.tokenRevoke,
    "mfaenroll": AuditAction.mfaEnroll,
    "mfaverify": AuditAction.mfaVerify
  ];
  return map.get(s.toLower, AuditAction.read_);
} 

/// Outcome of the audited operation.
enum AuditOutcome {
  success,
  failure,
  denied,
  error,
}
AuditOutcome toAuditOutcome(string s) {
  const map = [
    "success": AuditOutcome.success,
    "failure": AuditOutcome.failure,
    "denied": AuditOutcome.denied,
    "error": AuditOutcome.error
  ];
  return map.get(s.toLower, AuditOutcome.success);
}

/// Retention policy status.
enum RetentionStatus {
  active,
  inactive,
  expired,
}
RetentionStatus toRetentionStatus(string s) {
  const map = [
    "active": RetentionStatus.active,
    "inactive": RetentionStatus.inactive,
    "expired": RetentionStatus.expired
  ];
  return map.get(s.toLower, RetentionStatus.active);
}

/// Export job status.
enum ExportStatus {
  pending,
  inProgress,
  completed,
  failed,
}
ExportStatus toExportStatus(string s) {
  const map = [
    "pending": ExportStatus.pending,
    "inprogress": ExportStatus.inProgress,
    "completed": ExportStatus.completed,
    "failed": ExportStatus.failed
  ];
  return map.get(s.toLower, ExportStatus.pending);
}

/// Export output format.
enum ExportFormat {
  json,
  csv,
}
ExportFormat toExportFormat(string s) {
  const map = [
    "json": ExportFormat.json,
    "csv": ExportFormat.csv
  ];
  return map.get(s.toLower, ExportFormat.json);
}

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}
ConfigStatus toConfigStatus(string s) {
  const map = [
    "enabled": ConfigStatus.enabled,
    "disabled": ConfigStatus.disabled
  ];
  return map.get(s.toLower, ConfigStatus.enabled);
}
