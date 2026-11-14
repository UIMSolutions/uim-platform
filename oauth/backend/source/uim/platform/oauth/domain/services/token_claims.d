/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// JWT access token claims. The claim set follows the SAP XSUAA / UAA
/// conventions (zid, client_id, cid, user_id, scope as array, grant_type),
/// so tokens are understood by resolveRequestContext of uim-platform:service
/// and therefore by every platform service configured with the signing secret.
module uim.platform.oauth.domain.services.token_claims;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

Json accessTokenClaims(const AccessToken t, string issuer) {
  auto c = Json.emptyObject;
  c["iss"] = issuer;
  c["jti"] = t.id.value;
  c["zid"] = t.tenantId.value;
  c["client_id"] = t.clientId;
  c["cid"] = t.clientId;
  c["azp"] = t.clientId;
  c["sub"] = t.userId.length > 0 ? t.userId : t.clientId;
  if (t.userId.length > 0) {
    c["user_id"] = t.userId;
    c["user_name"] = t.userId;
  }
  auto scopes = Json.emptyArray;
  foreach (s; t.scopes)
    scopes ~= Json(s);
  c["scope"] = scopes;
  c["grant_type"] = cast(string) t.grantType;
  c["iat"] = unixSecondsOf(t.issuedAt);
  c["exp"] = unixSecondsOf(t.expiresAt);
  return c;
}

///
unittest {
  AccessToken t;
  t.id = AccessTokenId("j1");
  t.tenantId = TenantId("t1");
  t.clientId = "app";
  t.scopes = ["a", "b"];
  t.issuedAt = unixEpochStdTime + 10 * hnsecsPerSecond;
  t.expiresAt = unixEpochStdTime + 70 * hnsecsPerSecond;
  auto c = accessTokenClaims(t, "https://issuer");
  assert(c["sub"].get!string == "app" && "user_id" !in c);
  assert(c["zid"].get!string == "t1" && c["scope"].length == 2 && c["exp"].get!long == 70);
}
