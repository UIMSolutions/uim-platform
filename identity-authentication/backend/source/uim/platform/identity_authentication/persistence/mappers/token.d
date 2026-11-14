/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.token;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Token ⇄ snapshot record (only the token fingerprint is stored).
struct TokenMapper {
  static Json toRecord(const Token e) {
    auto r = baseRecord(e);
    r["userId"] = e.userId.value;
    r["applicationId"] = e.applicationId.value;
    r["sessionId"] = e.sessionId.value;
    r["tokenType"] = enumValue(e.tokenType);
    r["tokenHash"] = e.tokenHash;
    r["scopes"] = stringsRecord(e.scopes);
    r["issuedAt"] = e.issuedAt;
    r["expiresAt"] = e.expiresAt;
    r["revoked"] = e.revoked;
    return r;
  }

  static Token fromRecord(Json r) {
    Token e;
    readBase(e, r);
    e.userId = UserId(fieldString(r, "userId"));
    e.applicationId = ApplicationId(fieldString(r, "applicationId"));
    e.sessionId = SessionId(fieldString(r, "sessionId"));
    e.tokenType = fieldEnum!TokenType(r, "tokenType", TokenType.access);
    e.tokenHash = fieldString(r, "tokenHash");
    e.scopes = fieldStrings(r, "scopes");
    e.issuedAt = fieldLong(r, "issuedAt");
    e.expiresAt = fieldLong(r, "expiresAt");
    e.revoked = fieldBool(r, "revoked");
    return e;
  }
}
