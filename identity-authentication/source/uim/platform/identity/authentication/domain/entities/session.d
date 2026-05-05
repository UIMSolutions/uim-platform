/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.session;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Authenticated session.
struct IdaSession {
  mixin TenantEntity!SessionId;

  UserId userId;
  ApplicationId applicationId;
  AuthMethod authMethod;
  MfaType mfaUsed = MfaType.none;
  string ipAddress;
  string userAgent;
  RiskLevel riskLevel = RiskLevel.low;
  long expiresAt;
  bool revoked;

  Json toJson() const {
    return entityToJson
      .set("userId", userId)
      .set("applicationId", applicationId)
      .set("authMethod", authMethod.to!string())
      .set("mfaUsed", mfaUsed.to!string())
      .set("ipAddress", ipAddress)
      .set("userAgent", userAgent)
      .set("riskLevel", riskLevel.to!string())
      .set("expiresAt", expiresAt)
      .set("revoked", revoked);
  }
}
