module uim.platform.auditlog.domain.enumerations;
import uim.platform.auditlog;

// mixin(ShowModule!());
@safe:

// #region AuditCategory
/// Predefined SAP audit event categories.
enum AuditCategory {
  securityEvents, // audit.security-events
  configuration, // audit.configuration
  dataAccess, // audit.data-access
  dataModification, // audit.data-modification
}
AuditCategory toAuditCategory(string value) {
  switch(value.lower) {
    case "audit.security-events": return AuditCategory.securityEvents;
    case "audit.configuration": return AuditCategory.configuration;
    case "audit.data-access": return AuditCategory.dataAccess;
    case "audit.data-modification": return AuditCategory.dataModification;
    default: return AuditCategory.securityEvents;
  }
}
AuditCategory[] toAuditCategories(string[] values) {
  return values.map!(v => toAuditCategory(v)).array;
}

string toString(AuditCategory c) {
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
string[] toString(AuditCategory[] categories) {
  return categories.map!(c => toString(c)).array;
}
/// 
unittest {
  mixin(ShowTest!("AuditCategory"));

  assert(toAuditCategory("audit.security-events") == AuditCategory.securityEvents);
  assert(toAuditCategory("audit.configuration") == AuditCategory.configuration);
  assert(toAuditCategory("audit.data-access") == AuditCategory.dataAccess);
  assert(toAuditCategory("audit.data-modification") == AuditCategory.dataModification);

  assert(toString(AuditCategory.securityEvents) == "audit.security-events");
  assert(toString(AuditCategory.configuration) == "audit.configuration");
  assert(toString(AuditCategory.dataAccess) == "audit.data-access");
  assert(toString(AuditCategory.dataModification) == "audit.data-modification");

  assert(toAuditCategories(["audit.security-events", "audit.data-access"]) == [AuditCategory.securityEvents, AuditCategory.dataAccess]);
  assert(toString([AuditCategory.securityEvents, AuditCategory.dataAccess]) == ["audit.security-events", "audit.data-access"]);
}
// #endregion AuditCategory

/// Severity / log level of an audit event.
enum AuditSeverity {
  info,
  warning,
  error,
  critical,
}
AuditSeverity toAuditSeverity(string value) {
  mixin(EnumSwitch("AuditSeverity", "info"));
}
AuditSeverity[] toAuditSeverity(string[] values) {
  return values.map!(v => toAuditSeverity(v)).array;
}
string toString(AuditSeverity s) {
  return s.to!string();
}
string[] toString(AuditSeverity[] severities) {
  return severities.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("AuditSeverity"));

  assert(toAuditSeverity("info") == AuditSeverity.info);
  assert(toAuditSeverity("warning") == AuditSeverity.warning);
  assert(toAuditSeverity("error") == AuditSeverity.error);
  assert(toAuditSeverity("critical") == AuditSeverity.critical);

  assert(toString(AuditSeverity.info) == "info");
  assert(toString(AuditSeverity.warning) == "warning");
  assert(toString(AuditSeverity.error) == "error");
  assert(toString(AuditSeverity.critical) == "critical");

  assert(toAuditSeverity(["info", "error"]) == [AuditSeverity.info, AuditSeverity.error]);
  assert(toString([AuditSeverity.info, AuditSeverity.error]) == ["info", "error"]);
}

/// Concrete action that triggered the audit entry.
enum AuditAction : string {
  create = "create",
  read_ = "read",
  update = "update",
  delete_ = "delete",
  login = "login",
  logout = "logout",
  loginFailed = "loginFailed",
  passwordChange = "passwordChange",
  roleAssign = "roleAssign",
  roleRevoke = "roleRevoke",
  policyChange = "policyChange",
  configChange = "configChange",
  export_ = "export",
  dataAccess = "dataAccess",
  consentChange = "consentChange",
  tokenIssue = "tokenIssue",
  tokenRevoke = "tokenRevoke",
  mfaEnroll = "mfaEnroll",
  mfaVerify = "mfaVerify",
}
AuditAction toAuditAction(string value) {
  switch(value.toLower()) {
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
    default: return AuditAction.create; // default to create for unknown actions
  }
} 
AuditAction[] toAuditAction(string[] values) {
  return values.map!(v => toAuditAction(v)).array;
}
string toString(AuditAction a) {
  return cast(string)a;
}
string[] toString(AuditAction[] actions) {
  return actions.map!(a => toString(a)).array;
}
/// 
unittest {
  mixin(ShowTest!("AuditAction"));

  assert(toAuditAction("create") == AuditAction.create);
  assert(toAuditAction("read") == AuditAction.read_);
  assert(toAuditAction("update") == AuditAction.update);
  assert(toAuditAction("delete") == AuditAction.delete_);
  assert(toAuditAction("login") == AuditAction.login);
  assert(toAuditAction("logout") == AuditAction.logout);
  assert(toAuditAction("loginFailed") == AuditAction.loginFailed);
  assert(toAuditAction("passwordChange") == AuditAction.passwordChange);
  assert(toAuditAction("roleAssign") == AuditAction.roleAssign);
  assert(toAuditAction("roleRevoke") == AuditAction.roleRevoke);
  assert(toAuditAction("policyChange") == AuditAction.policyChange);
  assert(toAuditAction("configChange") == AuditAction.configChange);
  assert(toAuditAction("export") == AuditAction.export_);
  assert(toAuditAction("dataAccess") == AuditAction.dataAccess);
  assert(toAuditAction("consentChange") == AuditAction.consentChange);
  assert(toAuditAction("tokenIssue") == AuditAction.tokenIssue);
  assert(toAuditAction("tokenRevoke") == AuditAction.tokenRevoke);
  assert(toAuditAction("mfaEnroll") == AuditAction.mfaEnroll);
  assert(toAuditAction("mfaVerify") == AuditAction.mfaVerify);
  assert(toAuditAction("unknownAction") == AuditAction.create);

  assert(toString(AuditAction.create) == "create");
  assert(toString(AuditAction.read_) == "read");
  assert(toString(AuditAction.update) == "update");
  assert(toString(AuditAction.delete_) == "delete");
  assert(toString(AuditAction.login) == "login");
  assert(toString(AuditAction.logout) == "logout");
  assert(toString(AuditAction.loginFailed) == "loginFailed");
  assert(toString(AuditAction.passwordChange) == "passwordChange");
  assert(toString(AuditAction.roleAssign) == "roleAssign");
  assert(toString(AuditAction.roleRevoke) == "roleRevoke");
  assert(toString(AuditAction.policyChange) == "policyChange");
  assert(toString(AuditAction.configChange) == "configChange");
  assert(toString(AuditAction.export_) == "export");
  assert(toString(AuditAction.dataAccess) == "dataAccess");
  assert(toString(AuditAction.consentChange) == "consentChange");
  assert(toString(AuditAction.tokenIssue) == "tokenIssue");
  assert(toString(AuditAction.tokenRevoke) == "tokenRevoke");
  assert(toString(AuditAction.mfaEnroll) == "mfaEnroll");
  assert(toString(AuditAction.mfaVerify) == "mfaVerify");

  assert(toAuditAction(["create", "login"]) == [AuditAction.create, AuditAction.login]);
  assert(toString([AuditAction.create, AuditAction.login]) == ["create", "login"]);
} 

/// Outcome of the audited operation.
enum AuditOutcome {
  success,
  failure,
  denied,
  error,
}
AuditOutcome toAuditOutcome(string value) {
  mixin(EnumSwitch("AuditOutcome", "success"));
}
AuditOutcome[] toAuditOutcome(string[] values) {
  return values.map!(v => toAuditOutcome(v)).array;
}
string toString(AuditOutcome o) {
  return o.to!string();
}
string[] toString(AuditOutcome[] outcomes) {
  return outcomes.map!(o => toString(o)).array;
}
/// 
unittest {
  mixin(ShowTest!("AuditOutcome"));

  assert(toAuditOutcome("success") == AuditOutcome.success);
  assert(toAuditOutcome("failure") == AuditOutcome.failure);
  assert(toAuditOutcome("denied") == AuditOutcome.denied);
  assert(toAuditOutcome("error") == AuditOutcome.error);

  assert(toString(AuditOutcome.success) == "success");
  assert(toString(AuditOutcome.failure) == "failure");
  assert(toString(AuditOutcome.denied) == "denied");
  assert(toString(AuditOutcome.error) == "error");

  assert(toAuditOutcome(["success", "failure"]) == [AuditOutcome.success, AuditOutcome.failure]);
  assert(toString([AuditOutcome.success, AuditOutcome.failure]) == ["success", "failure"]);
}

/// Retention policy status.
enum RetentionStatus {
  active,
  inactive,
  expired,
}
RetentionStatus toRetentionStatus(string value) {
  mixin(EnumSwitch("RetentionStatus", "active"));
}
RetentionStatus[] toRetentionStatus(string[] values) {
  return values.map!(v => toRetentionStatus(v)).array;
}
string toString(RetentionStatus s) {
  return s.to!string();
}
string[] toString(RetentionStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("RetentionStatus"));

  assert(toRetentionStatus("active") == RetentionStatus.active);
  assert(toRetentionStatus("inactive") == RetentionStatus.inactive);
  assert(toRetentionStatus("expired") == RetentionStatus.expired);

  assert(toString(RetentionStatus.active) == "active");
  assert(toString(RetentionStatus.inactive) == "inactive");
  assert(toString(RetentionStatus.expired) == "expired");

  assert(toRetentionStatus(["active", "expired"]) == [RetentionStatus.active, RetentionStatus.expired]);
  assert(toString([RetentionStatus.active, RetentionStatus.expired]) == ["active", "expired"]);
}

/// Export job status.
enum ExportStatus {
  pending,
  inProgress,
  completed,
  failed,
}
ExportStatus toExportStatus(string value) {
  mixin(EnumSwitch("ExportStatus", "pending"));
}
ExportStatus[] toExportStatus(string[] values) {
  return values.map!(v => toExportStatus(v)).array;
}
string toString(ExportStatus s) {
  return s.to!string();
}
string[] toString(ExportStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("ExportStatus"));

  assert(toExportStatus("pending") == ExportStatus.pending);
  assert(toExportStatus("inProgress") == ExportStatus.inProgress);
  assert(toExportStatus("completed") == ExportStatus.completed);
  assert(toExportStatus("failed") == ExportStatus.failed);

  assert(toString(ExportStatus.pending) == "pending");
  assert(toString(ExportStatus.inProgress) == "inProgress");
  assert(toString(ExportStatus.completed) == "completed");
  assert(toString(ExportStatus.failed) == "failed");

  assert(toExportStatus(["pending", "completed"]) == [ExportStatus.pending, ExportStatus.completed]);
  assert(toString([ExportStatus.pending, ExportStatus.completed]) == ["pending", "completed"]);
}

/// Export output format.
enum ExportFormat {
  json,
  csv,
}
ExportFormat toExportFormat(string value) {
  mixin(EnumSwitch("ExportFormat", "json"));
}
ExportFormat[] toExportFormat(string[] values) {
  return values.map!(v => toExportFormat(v)).array;
}
string toString(ExportFormat f) {
  return f.to!string();
}
string[] toString(ExportFormat[] formats) {
  return formats.map!(f => toString(f)).array;
}
/// 
unittest {
  mixin(ShowTest!("ExportFormat"));

  assert(toExportFormat("json") == ExportFormat.json);
  assert(toExportFormat("csv") == ExportFormat.csv);  

  assert(toString(ExportFormat.json) == "json");
  assert(toString(ExportFormat.csv) == "csv");

  assert(toExportFormat(["json", "csv"]) == [ExportFormat.json, ExportFormat.csv]);
  assert(toString([ExportFormat.json, ExportFormat.csv]) == ["json", "csv"]);
}

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}
ConfigStatus toConfigStatus(string value) {
  mixin(EnumSwitch("ConfigStatus", "enabled"));
}
ConfigStatus[] toConfigStatus(string[] values) {
  return values.map!(v => toConfigStatus(v)).array;
}
string toString(ConfigStatus s) {
  return s.to!string();
}
string[] toString(ConfigStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("ConfigStatus")); 

  assert(toConfigStatus("enabled") == ConfigStatus.enabled);
  assert(toConfigStatus("disabled") == ConfigStatus.disabled);  

  assert(toString(ConfigStatus.enabled) == "enabled");
  assert(toString(ConfigStatus.disabled) == "disabled");

  assert(toConfigStatus(["enabled", "disabled"]) == [ConfigStatus.enabled, ConfigStatus.disabled]);
  assert(toString([ConfigStatus.enabled, ConfigStatus.disabled]) == ["enabled", "disabled"]);
}
