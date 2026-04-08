/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.token;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Issued security token.
struct Token {
  TokenId id;
  UserId userId;
  TenantId tenantId;
  ApplicationId applicationId;
  TokenType tokenType;
  string tokenValue;
  string[] scopes;
  long issuedAt;
  long expiresAt;
  bool revoked;

  Json toJson() {
    return Json.emptyObject.set("id", id.toString).set("userId", userId).set("tenantId",
        tenantId).set("applicationId", applicationId).set("tokenType",
        to!string(tokenType)).set("tokenValue", tokenValue).set("scopes", scopes)
      .set("issuedAt", issuedAt).set("expiresAt", expiresAt).set("revoked", revoked);
  }
}
