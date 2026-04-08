/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:

/// Unique identifier type aliases for type safety.
struct AuditLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}

struct RetentionPolicyId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}

struct AuditConfigId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}

struct ExportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}
struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}

struct ServiceId {
  string value;

  this(string value) {
    this.value = value;
  }

  string toString() const {
    return value;
  }
}

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
