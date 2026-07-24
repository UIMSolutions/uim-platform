/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations;
import uim.platform.auditlog;

mixin(ShowModule!());

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
  switch (value.lower) {
  case "audit.security-events":
    return AuditCategory.securityEvents;
  case "audit.configuration":
    return AuditCategory.configuration;
  case "audit.data-access":
    return AuditCategory.dataAccess;
  case "audit.data-modification":
    return AuditCategory.dataModification;
  default:
    return AuditCategory.securityEvents;
  }
}

AuditCategory[] toAuditCategories(string[] values) {
  return values.map!toAuditCategory.array;
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

string[] toStrings(AuditCategory[] categories) {
  return categories.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditCategory"));

  assert("audit.security-events".toAuditCategory == AuditCategory.securityEvents);
  assert("audit.configuration".toAuditCategory == AuditCategory.configuration);
  assert("audit.data-access".toAuditCategory == AuditCategory.dataAccess);
  assert("audit.data-modification".toAuditCategory == AuditCategory.dataModification);

  assert(AuditCategory.securityEvents.toString == "audit.security-events");
  assert(AuditCategory.configuration.toString == "audit.configuration");
  assert(AuditCategory.dataAccess.toString == "audit.data-access");
  assert(AuditCategory.dataModification.toString == "audit.data-modification");

  assert(["audit.security-events", "audit.data-access"].toAuditCategories == [
      AuditCategory.securityEvents, AuditCategory.dataAccess
    ]);
  assert([AuditCategory.securityEvents, AuditCategory.dataAccess].toStrings == [
      "audit.security-events", "audit.data-access"
    ]);
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

AuditSeverity[] toAuditSeverities(string[] values) {
  return values.map!toAuditSeverity.array;
}

string toString(AuditSeverity s) {
  return s.to!string;
}

string[] toStrings(AuditSeverity[] severities) {
  return severities.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditSeverity"));

  assert("info".toAuditSeverity == AuditSeverity.info);
  assert("warning".toAuditSeverity == AuditSeverity.warning);
  assert("error".toAuditSeverity == AuditSeverity.error);
  assert("critical".toAuditSeverity == AuditSeverity.critical);

  assert(AuditSeverity.info.toString == "info");
  assert(AuditSeverity.warning.toString == "warning");
  assert(AuditSeverity.error.toString == "error");
  assert(AuditSeverity.critical.toString == "critical");

  assert(toAuditSeverities(["info", "error"]) == [
      AuditSeverity.info, AuditSeverity.error
    ]);
  assert([AuditSeverity.info, AuditSeverity.error].toStrings == [
      "info", "error"
    ]);
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
  switch (value.toLower()) {
  case "create":
    return AuditAction.create;
  case "read":
    return AuditAction.read_;
  case "update":
    return AuditAction.update;
  case "delete":
    return AuditAction.delete_;
  case "login":
    return AuditAction.login;
  case "logout":
    return AuditAction.logout;
  case "loginfailed":
    return AuditAction.loginFailed;
  case "passwordchange":
    return AuditAction.passwordChange;
  case "roleassign":
    return AuditAction.roleAssign;
  case "rolerevoke":
    return AuditAction.roleRevoke;
  case "policychange":
    return AuditAction.policyChange;
  case "configchange":
    return AuditAction.configChange;
  case "export":
    return AuditAction.export_;
  case "dataaccess":
    return AuditAction.dataAccess;
  case "consentchange":
    return AuditAction.consentChange;
  case "tokenissue":
    return AuditAction.tokenIssue;
  case "tokenrevoke":
    return AuditAction.tokenRevoke;
  case "mfaenroll":
    return AuditAction.mfaEnroll;
  case "mfaverify":
    return AuditAction.mfaVerify;
  default:
    return AuditAction.create; // default to create for unknown actions
  }
}

AuditAction[] toAuditActions(string[] values) {
  return values.map!toAuditAction.array;
}

string toString(AuditAction action) {
  return cast(string)action;
}

string[] toStrings(AuditAction[] actions) {
  return actions.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditAction"));

  assert("create".toAuditAction == AuditAction.create);
  assert("read".toAuditAction == AuditAction.read_);
  assert("update".toAuditAction == AuditAction.update);
  assert("delete".toAuditAction == AuditAction.delete_);
  assert("login".toAuditAction == AuditAction.login);
  assert("logout".toAuditAction == AuditAction.logout);
  assert("loginFailed".toAuditAction == AuditAction.loginFailed);
  assert("passwordChange".toAuditAction == AuditAction.passwordChange);
  assert("roleAssign".toAuditAction == AuditAction.roleAssign);
  assert("roleRevoke".toAuditAction == AuditAction.roleRevoke);
  assert("policyChange".toAuditAction == AuditAction.policyChange);
  assert("configChange".toAuditAction == AuditAction.configChange);
  assert("export".toAuditAction == AuditAction.export_);
  assert("dataAccess".toAuditAction == AuditAction.dataAccess);
  assert("consentChange".toAuditAction == AuditAction.consentChange);
  assert("tokenIssue".toAuditAction == AuditAction.tokenIssue);
  assert("tokenRevoke".toAuditAction == AuditAction.tokenRevoke);
  assert("mfaEnroll".toAuditAction == AuditAction.mfaEnroll);
  assert("mfaVerify".toAuditAction == AuditAction.mfaVerify);
  assert("unknownAction".toAuditAction == AuditAction.create);

  assert(AuditAction.create.toString == "create");
  assert(AuditAction.read_.toString == "read");
  assert(AuditAction.update.toString == "update");
  assert(AuditAction.delete_.toString == "delete");
  assert(AuditAction.login.toString == "login");
  assert(AuditAction.logout.toString == "logout");
  assert(AuditAction.loginFailed.toString == "loginFailed");
  assert(AuditAction.passwordChange.toString == "passwordChange");
  assert(AuditAction.roleAssign.toString == "roleAssign");
  assert(AuditAction.roleRevoke.toString == "roleRevoke");
  assert(AuditAction.policyChange.toString == "policyChange");
  assert(AuditAction.configChange.toString == "configChange");
  assert(AuditAction.export_.toString == "export");
  assert(AuditAction.dataAccess.toString == "dataAccess");
  assert(AuditAction.consentChange.toString == "consentChange");
  assert(AuditAction.tokenIssue.toString == "tokenIssue");
  assert(AuditAction.tokenRevoke.toString == "tokenRevoke");
  assert(AuditAction.mfaEnroll.toString == "mfaEnroll");
  assert(AuditAction.mfaVerify.toString == "mfaVerify");

  assert(["create", "login"].toAuditActions == [
      AuditAction.create, AuditAction.login
    ]);
  assert([AuditAction.create, AuditAction.login].toStrings == [
      "create", "login"
    ]);
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

AuditOutcome[] toAuditOutcomes(string[] values) {
  return values.map!toAuditOutcome.array;
}

string toString(AuditOutcome o) {
  return o.to!string;
}

string[] toStrings(AuditOutcome[] outcomes) {
  return outcomes.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditOutcome"));

  assert("success".toAuditOutcome == AuditOutcome.success);
  assert("failure".toAuditOutcome == AuditOutcome.failure);
  assert("denied".toAuditOutcome == AuditOutcome.denied);
  assert("error".toAuditOutcome == AuditOutcome.error);

  assert(AuditOutcome.success.toString == "success");
  assert(AuditOutcome.failure.toString == "failure");
  assert(AuditOutcome.denied.toString == "denied");
  assert(AuditOutcome.error.toString == "error");

  assert(["success", "failure"].toAuditOutcomes == [
      AuditOutcome.success, AuditOutcome.failure
    ]);
  assert([AuditOutcome.success, AuditOutcome.failure].toStrings == [
      "success", "failure"
    ]);
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

RetentionStatus[] toRetentionStatuses(string[] values) {
  return values.map!toRetentionStatus.array;
}

string toString(RetentionStatus s) {
  return s.to!string;
}

string[] toStrings(RetentionStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("RetentionStatus"));

  assert("active".toRetentionStatus == RetentionStatus.active);
  assert("inactive".toRetentionStatus == RetentionStatus.inactive);
  assert("expired".toRetentionStatus == RetentionStatus.expired);

  assert(RetentionStatus.active.toString == "active");
  assert(RetentionStatus.inactive.toString == "inactive");
  assert(RetentionStatus.expired.toString == "expired");

  assert(["active", "expired"].toRetentionStatuses == [
      RetentionStatus.active, RetentionStatus.expired
    ]);
  assert([RetentionStatus.active, RetentionStatus.expired].toStrings == [
      "active", "expired"
    ]);
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

ExportStatus[] toExportStatuses(string[] values) {
  return values.map!toExportStatus.array;
}

string toString(ExportStatus s) {
  return s.to!string;
}

string[] toStrings(ExportStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ExportStatus"));

  assert("pending".toExportStatus == ExportStatus.pending);
  assert("inProgress".toExportStatus == ExportStatus.inProgress);
  assert("completed".toExportStatus == ExportStatus.completed);
  assert("failed".toExportStatus == ExportStatus.failed);

  assert(ExportStatus.pending.toString == "pending");
  assert(ExportStatus.inProgress.toString == "inProgress");
  assert(ExportStatus.completed.toString == "completed");
  assert(ExportStatus.failed.toString == "failed");

  assert(["pending", "completed"].toExportStatuses == [
      ExportStatus.pending, ExportStatus.completed
    ]);
  assert([ExportStatus.pending, ExportStatus.completed].toStrings == [
      "pending", "completed"
    ]);
}

/// Export output format.
enum ExportFormat {
  json,
  csv,
}

ExportFormat toExportFormat(string value) {
  mixin(EnumSwitch("ExportFormat", "json"));
}

ExportFormat[] toExportFormats(string[] values) {
  return values.map!toExportFormat.array;
}

string toString(ExportFormat f) {
  return f.to!string;
}

string[] toStrings(ExportFormat[] formats) {
  return formats.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ExportFormat"));

  assert("json".toExportFormat == ExportFormat.json);
  assert("csv".toExportFormat == ExportFormat.csv);

  assert(ExportFormat.json.toString == "json");
  assert(ExportFormat.csv.toString == "csv");

  assert(["json", "csv"].toExportFormats == [
      ExportFormat.json, ExportFormat.csv
    ]);
  assert([ExportFormat.json, ExportFormat.csv].toStrings == ["json", "csv"]);
}

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}

ConfigStatus toConfigStatus(string value) {
  mixin(EnumSwitch("ConfigStatus", "enabled"));
}

ConfigStatus[] toConfigStatuses(string[] values) {
  return values.map!toConfigStatus.array;
}

string toString(ConfigStatus s) {
  return s.to!string;
}

string[] toStrings(ConfigStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ConfigStatus"));

  assert("enabled".toConfigStatus == ConfigStatus.enabled);
  assert("disabled".toConfigStatus == ConfigStatus.disabled);

  assert(ConfigStatus.enabled.toString == "enabled");
  assert(ConfigStatus.disabled.toString == "disabled");

  assert(["enabled", "disabled"].toConfigStatuses == [
      ConfigStatus.enabled, ConfigStatus.disabled
    ]);
  assert([ConfigStatus.enabled, ConfigStatus.disabled].toStrings == [
      "enabled", "disabled"
    ]);
}
