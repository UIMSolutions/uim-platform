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
  switch(s.lower) {
    case "audit.security-events": return AuditCategory.securityEvents;
    case "audit.configuration": return AuditCategory.configuration;
    case "audit.data-access": return AuditCategory.dataAccess;
    case "audit.data-modification": return AuditCategory.dataModification;
    default: return AuditCategory.securityEvents;
  }
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
  switch(s.lower) {
    case "info": return AuditSeverity.info;
    case "warning": return AuditSeverity.warning;
    case "error": return AuditSeverity.error;
    case "critical": return AuditSeverity.critical;
    default: return AuditSeverity.info;
  }
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
  switch(s.lower) {
    case "create": return AuditAction.create;
    case "read": return AuditAction.read_;
    case "update": return AuditAction.update;
    case "delete": return AuditAction.delete_;
    case "login": return AuditAction.login;
    case "logout": return AuditAction.logout;
    case "loginfailed": return AuditAction.loginFailed;
    case "passwordchange": return AuditAction.passwordChange;
    case "roleassign": return AuditAction.roleAssign;
    case "rolerevoke": return AuditAction.roleRevoke;
    case "policychange": return AuditAction.policyChange;
    case "configchange": return AuditAction.configChange;
    case "export": return AuditAction.export_;
    case "dataaccess": return AuditAction.dataAccess;
    case "consentchange": return AuditAction.consentChange;
    case "tokenissue": return AuditAction.tokenIssue;
    case "tokenrevoke": return AuditAction.tokenRevoke;
    case "mfaenroll": return AuditAction.mfaEnroll;
    case "mfaverify": return AuditAction.mfaVerify;
    default: return AuditAction.read_;
  }
} 

/// Outcome of the audited operation.
enum AuditOutcome {
  success,
  failure,
  denied,
  error,
}
AuditOutcome toAuditOutcome(string s) {
  switch(s.lower) {
    case "success": return AuditOutcome.success;
    case "failure": return AuditOutcome.failure;
    case "denied": return AuditOutcome.denied;
    case "error": return AuditOutcome.error;
    default: return AuditOutcome.success;
  }
}

/// Retention policy status.
enum RetentionStatus {
  active,
  inactive,
  expired,
}
RetentionStatus toRetentionStatus(string s) {
  switch(s.lower) {
    case "active": return RetentionStatus.active;
    case "inactive": return RetentionStatus.inactive;
    case "expired": return RetentionStatus.expired;
    default: return RetentionStatus.active;
  }
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
  switch(s.lower) {
    case "pending": return ExportStatus.pending;
    case "inprogress": return ExportStatus.inProgress;
    case "completed": return ExportStatus.completed;
    case "failed": return ExportStatus.failed;
    default: return ExportStatus.pending;
  }
}

/// Export output format.
enum ExportFormat {
  json,
  csv,
}
ExportFormat toExportFormat(string s) {
  switch(s.lower) {
    case "json": return ExportFormat.json;
    case "csv": return ExportFormat.csv;
    default: return ExportFormat.json;
  }
}

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}
ConfigStatus toConfigStatus(string s) {
  switch(s.lower) {
    case "enabled": return ConfigStatus.enabled;
    case "disabled": return ConfigStatus.disabled;
    default: return ConfigStatus.enabled;
  }
}
