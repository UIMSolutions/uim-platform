/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.session;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Authenticated (SSO) session.
struct IASession {
  mixin TenantEntity!SessionId;

  UserId userId;
  ApplicationId applicationId;
  AuthMethod authMethod = AuthMethod.form;
  MfaType mfaUsed = MfaType.none;
  string ipAddress;
  string userAgent;
  RiskLevel riskLevel = RiskLevel.low;
  long expiresAt;
  bool revoked;

  bool isExpired(long now) const {
    return expiresAt > 0 && expiresAt <= now;
  }

  bool isActive(long now) const {
    return !revoked && !isExpired(now);
  }

  Json toJson() const {
    return entityToJson
      .set("userId", userId.value)
      .set("applicationId", applicationId.value)
      .set("authMethod", enumValue(authMethod))
      .set("mfaUsed", enumValue(mfaUsed))
      .set("ipAddress", ipAddress)
      .set("userAgent", userAgent)
      .set("riskLevel", enumValue(riskLevel))
      .set("expiresAt", expiresAt)
      .set("revoked", revoked);
  }
}
