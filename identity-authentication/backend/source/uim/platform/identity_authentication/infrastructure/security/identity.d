/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.security.identity;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Who is calling the administration APIs, derived from the request.
struct RequestIdentity {
  TenantId tenantId;
  UserId userId;
  string userName;
  string[] scopes;
  /// True if the values were taken from a bearer token.
  bool fromToken;
  /// True if the token signature was verified by this service.
  bool verified;
}

/// The token of an "Authorization: Bearer <token>" header ("" otherwise).
string bearerToken(string authorizationHeader) {
  auto h = authorizationHeader.strip;
  return h.length > 7 && sicmp(h[0 .. 7], "Bearer ") == 0 ? h[7 .. $].strip : "";
}

/// Decode the claims (payload) of a JWT WITHOUT verifying the signature.
Json decodeJwtClaims(string token) {
  auto parts = token.split(".");
  if (parts.length != 3)
    return Json.undefined;
  try
    return parseJsonString(cast(string) fromBase64Url(parts[1]).idup);
  catch (Exception)
    return Json.undefined;
}

/// Resolve the caller identity, in this order:
///   1. a bearer token issued (and verified) by this service
///   2. an XSUAA bearer token forwarded by the approuter (zid / user_name / scope)
///   3. the X-Tenant-Id / X-User-Id headers, else the default tenant
///
/// SECURITY: case 2 does not verify the XSUAA signature — behind the approuter
/// the token has already been validated by XSUAA, but a directly reachable
/// backend must validate it (XSUAA verification key / JWKS) or be firewalled.
RequestIdentity resolveIdentity(string authorizationHeader, string tenantHeader, string userHeader,
    string defaultTenant, ITokenService verifier = null) {
  RequestIdentity identity;
  auto token = bearerToken(authorizationHeader);

  if (token.length) {
    TokenClaims claims;
    if (verifier !is null && verifier.verify(token, Clock.currStdTime(), claims)) {
      identity.fromToken = true;
      identity.verified = true;
      identity.tenantId = claims.tenantId;
      identity.userId = UserId(claims.subject);
      identity.userName = claims.userName;
      identity.scopes = claims.scopes;
    } else {
      auto c = decodeJwtClaims(token);
      if (c.type == Json.Type.object) {
        identity.fromToken = true;
        identity.tenantId = TenantId(fieldString(c, "zid"));
        identity.userName = fieldString(c, "user_name");
        identity.userId = UserId(fieldString(c, "user_id", identity.userName));
        identity.scopes = fieldStrings(c, "scope");
      }
    }
  }

  if (identity.tenantId.isEmpty)
    identity.tenantId = TenantId(tenantHeader.length > 0 ? tenantHeader : defaultTenant);
  if (identity.userId.isEmpty && userHeader.length > 0) {
    identity.userId = UserId(userHeader);
    identity.userName = userHeader;
  }
  return identity;
}

///
unittest {
  mixin(ShowTest!("resolveIdentity"));

  auto payload = base64Url(cast(const(ubyte)[]) `{"zid":"tenant-a","user_name":"jane","scope":["ias.Read"]}`);
  auto xsuaa = "eyJhbGciOiJub25lIn0." ~ payload ~ ".sig";
  auto fromXsuaa = resolveIdentity("Bearer " ~ xsuaa, "", "", "default");
  assert(fromXsuaa.fromToken && !fromXsuaa.verified);
  assert(fromXsuaa.tenantId.value == "tenant-a" && fromXsuaa.userName == "jane");

  auto signer = new JwtTokenService("k");
  TokenClaims c;
  c.subject = "u7";
  c.tenantId = TenantId("t7");
  c.expiresAt = Clock.currStdTime() + 600_000_000L;
  auto own = resolveIdentity("bearer " ~ signer.sign(c), "", "", "default", signer);
  assert(own.verified && own.tenantId.value == "t7" && own.userId.value == "u7");

  auto fromHeader = resolveIdentity("", "t2", "bob", "default");
  assert(!fromHeader.fromToken && fromHeader.tenantId.value == "t2" && fromHeader.userId.value == "bob");
  assert(resolveIdentity("", "", "", "default").tenantId.value == "default");
  assert(bearerToken("Basic abc") == "");
}
