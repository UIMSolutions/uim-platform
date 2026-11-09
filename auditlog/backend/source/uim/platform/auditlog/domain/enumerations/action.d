/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.action;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

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

AuditAction[] toAuditAction(string[] values) {
  return values.map!toAuditAction.array;
}

string toString(AuditAction action) {
  return cast(string)action;
}

string[] toString(AuditAction[] actions) {
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

  assert(["create", "login"].toAuditAction == [AuditAction.create, AuditAction.login
    ]);
  assert([AuditAction.create, AuditAction.login].toString == ["create", "login"
    ]);
}

