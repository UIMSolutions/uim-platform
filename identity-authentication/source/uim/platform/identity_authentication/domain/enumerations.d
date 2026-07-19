module uim.platform.identity_authentication.domain.enumerations;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Multi-factor authentication type.
enum MfaType {
  none,
  totp,
  sms,
  email,
} 
MfaType toMfaType(string value) {
  mixin(EnumSwitch("MfaType", "none"));
}
MfaType[] toMfaType(string[] values) {
  return values.map!(v => v.toMfaType).array;
}
string toString(MfaType value) {
  return value.to!string();
}
string[] toStrings(MfaType[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("MfaType"));

  assert("none".toMfaType == MfaType.none);
  assert("totp".toMfaType == MfaType.totp);
  assert("sms".toMfaType == MfaType.sms);
  assert("email".toMfaType == MfaType.email);

  assert(MfaType.none.toString == "none");
  assert(MfaType.totp.toString == "totp");
  assert(MfaType.sms.toString == "sms");
  assert(MfaType.email.toString == "email");

  assert(["none", "totp"].toMfaType == [MfaType.none, MfaType.totp]);
  assert([MfaType.none, MfaType.totp].toStrings == ["none", "totp"]);
}

/// IAUser status in the identity directory.
enum UserStatus {
  active,
  inactive,
  locked,
  pendingVerification,
}
UserStatus toUserStatus(string value) {
  mixin(EnumSwitch("UserStatus", "active"));
}
UserStatus[] toUserStatuses(string[] values) {
  return values.map!(v => v.toUserStatus).array;
}
string toString(UserStatus value) {
  return value.to!string();
}
string[] toStrings(UserStatus[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("UserStatus"));

  assert("active".toUserStatus == UserStatus.active);
  assert("inactive".toUserStatus == UserStatus.inactive);
  assert("locked".toUserStatus == UserStatus.locked);
  assert("pendingVerification".toUserStatus == UserStatus.pendingVerification);
  assert("unknown".toUserStatus == UserStatus.active); // default

  assert(UserStatus.active.toString == "active");
  assert(UserStatus.inactive.toString == "inactive");
  assert(UserStatus.locked.toString == "locked");
  assert(UserStatus.pendingVerification.toString == "pendingVerification");

  assert(["active", "locked"].toUserStatus == [UserStatus.active, UserStatus.locked]);
  assert([UserStatus.active, UserStatus.locked].toStrings == ["active", "locked"]);
}

/// Risk level determined by risk-based authentication.
enum RiskLevel {
  /// Low risk level. 
  low,
  /// Medium risk level.
  medium,
  /// High risk level.
  high,
  /// Critical risk level.
  critical,
}
RiskLevel toRiskLevel(string value) {
  mixin(EnumSwitch("RiskLevel", "low"));
}
RiskLevel[] toRiskLevel(string[] values) {
  return values.map!(v => v.toRiskLevel).array;
}
string toString(RiskLevel value) {
  return value.to!string();
}
string[] toStrings(RiskLevel[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("RiskLevel"));

  assert("low".toRiskLevel == RiskLevel.low);
  assert("medium".toRiskLevel == RiskLevel.medium);
  assert("high".toRiskLevel == RiskLevel.high);
  assert("critical".toRiskLevel == RiskLevel.critical);

  assert("unknown".toRiskLevel == RiskLevel.low); // default
  assert("".toRiskLevel == RiskLevel.low); // default

  assert(RiskLevel.low.toString == "low");
  assert(RiskLevel.medium.toString == "medium");
  assert(RiskLevel.high.toString == "high");
  assert(RiskLevel.critical.toString == "critical");    
 
  assert(["low", "high"].toRiskLevel == [RiskLevel.low, RiskLevel.high]);
  assert([RiskLevel.low, RiskLevel.high].toStrings == ["low", "high"]);
}

/// Token type.
enum TokenType {
  access,
  refresh,
  idToken,
  samlAssertion,
}
TokenType toTokenType(string value) {
  mixin(EnumSwitch("TokenType", "access"));
}
TokenType[] toTokenType(string[] values) {
  return values.map!(v => v.toTokenType).array;
}
string toString(TokenType value) {
  return value.to!string();
}
string[] toStrings(TokenType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("TokenType"));

  assert("access".toTokenType == TokenType.access);
  assert("refresh".toTokenType == TokenType.refresh);
  assert("idToken".toTokenType == TokenType.idToken);
  assert("samlAssertion".toTokenType == TokenType.samlAssertion);
  assert("unknown".toTokenType == TokenType.access); // default

  assert(TokenType.access.toString == "access");
  assert(TokenType.refresh.toString == "refresh");
  assert(TokenType.idToken.toString == "idToken");
  assert(TokenType.samlAssertion.toString == "samlAssertion");

  assert(["access", "idToken"].toTokenType == [TokenType.access, TokenType.idToken]);
  assert([TokenType.access, TokenType.idToken].toStrings == ["access", "idToken"]);
}

/// Provisioning job status.
enum JobStatus {
  pending,
  running,
  completed,
  failed,
}
JobStatus toJobStatus(string value) {
  mixin(EnumSwitch("JobStatus", "pending"));
}
JobStatus[] toJobStatuses(string[] values) {
  return values.map!(v => v.toJobStatus).array;
}
string toString(JobStatus value) {
  return value.to!string();
}
string[] toStrings(JobStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("JobStatus"));

  assert("pending".toJobStatus == JobStatus.pending);
  assert("running".toJobStatus == JobStatus.running);
  assert("completed".toJobStatus == JobStatus.completed);
  assert("failed".toJobStatus == JobStatus.failed);
  assert("unknown".toJobStatus == JobStatus.pending); // default

  assert(JobStatus.pending.toString == "pending");
  assert(JobStatus.running.toString == "running");
  assert(JobStatus.completed.toString == "completed");
  assert(JobStatus.failed.toString == "failed");

  assert(["pending", "completed"].toJobStatus == [JobStatus.pending, JobStatus.completed]);
  assert([JobStatus.pending, JobStatus.completed].toStrings == ["pending", "completed"]);
}

/// Identity provider type for delegation.
enum IdpType {
  local,
  saml,
  oidc,
  ldap,
  corporate,
}
IdpType toIdpType(string value) {
  mixin(EnumSwitch("IdpType", "local"));
}
IdpType[] toIdpType(string[] values) {
  return values.map!(v => v.toIdpType).array;
}
string toString(IdpType value) {
  return value.to!string();
}
string[] toStrings(IdpType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("IdpType"));

  assert("local".toIdpType == IdpType.local);
  assert("saml".toIdpType == IdpType.saml);
  assert("oidc".toIdpType == IdpType.oidc);
  assert("ldap".toIdpType == IdpType.ldap);
  assert("corporate".toIdpType == IdpType.corporate);
  assert("unknown".toIdpType == IdpType.local); // default

  assert(IdpType.local.toString == "local");
  assert(IdpType.saml.toString == "saml");
  assert(IdpType.oidc.toString == "oidc");
  assert(IdpType.ldap.toString == "ldap");
  assert(IdpType.corporate.toString == "corporate");    

  assert(["local", "saml"].toIdpType == [IdpType.local, IdpType.saml]);
  assert([IdpType.local, IdpType.saml].toStrings == ["local", "saml"]);
}
