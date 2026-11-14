/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.session;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// IASession ⇄ snapshot record.
struct SessionMapper {
  static Json toRecord(const IASession e) {
    auto r = baseRecord(e);
    r["userId"] = e.userId.value;
    r["applicationId"] = e.applicationId.value;
    r["authMethod"] = enumValue(e.authMethod);
    r["mfaUsed"] = enumValue(e.mfaUsed);
    r["ipAddress"] = e.ipAddress;
    r["userAgent"] = e.userAgent;
    r["riskLevel"] = enumValue(e.riskLevel);
    r["expiresAt"] = e.expiresAt;
    r["revoked"] = e.revoked;
    return r;
  }

  static IASession fromRecord(Json r) {
    IASession e;
    readBase(e, r);
    e.userId = UserId(fieldString(r, "userId"));
    e.applicationId = ApplicationId(fieldString(r, "applicationId"));
    e.authMethod = fieldEnum!AuthMethod(r, "authMethod", AuthMethod.form);
    e.mfaUsed = fieldEnum!MfaType(r, "mfaUsed", MfaType.none);
    e.ipAddress = fieldString(r, "ipAddress");
    e.userAgent = fieldString(r, "userAgent");
    e.riskLevel = fieldEnum!RiskLevel(r, "riskLevel", RiskLevel.low);
    e.expiresAt = fieldLong(r, "expiresAt");
    e.revoked = fieldBool(r, "revoked");
    return e;
  }
}
