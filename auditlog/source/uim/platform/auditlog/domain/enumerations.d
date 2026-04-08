module uim.platform.auditlog.domain.enumerations;


/// Predefined SAP audit event categories.
enum AuditCategory {
  securityEvents, // audit.security-events
  configuration, // audit.configuration
  dataAccess, // audit.data-access
  dataModification, // audit.data-modification
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
