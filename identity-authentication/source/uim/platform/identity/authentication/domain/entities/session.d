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
  SessionId id;
  UserId userId;
  TenantId tenantId;
  ApplicationId applicationId;
  AuthMethod authMethod;
  MfaType mfaUsed = MfaType.none;
  string ipAddress;
  string userAgent;
  RiskLevel riskLevel = RiskLevel.low;
  long createdAt;
  long expiresAt;
  bool revoked;
}
