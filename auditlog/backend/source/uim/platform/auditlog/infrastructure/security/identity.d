/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.security.identity;

import std.base64 : Base64URLNoPadding;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Who is calling, derived from the request.
struct RequestIdentity {
  TenantId tenantId;
  UserId userId;
  string userName;
  string[] scopes;
  /// True if the values were taken from a bearer token (XSUAA JWT).
  bool fromToken;
}

/// Decode the claims (payload) of a JWT.
///
/// SECURITY: this does NOT verify the token signature. Claims are only trusted
/// as much as the X-Tenant-Id header: behind the approuter the token has already
/// been validated by XSUAA, but a directly reachable backend must validate the
/// signature (XSUAA verification key / JWKS) before relying on these claims.
Json decodeJwtClaims(string token) {
  auto parts = token.split(".");
  if (parts.length != 3)
    return Json.undefined;
  try {
    auto bytes = Base64URLNoPadding.decode(parts[1].stripRight("="));
    auto payload = (() @trusted => cast(string) bytes)();
    return parseJsonString(payload);
  } catch (Exception) {
    return Json.undefined;
  }
}

/// Resolve the caller identity from (in this order) an XSUAA bearer token
/// (zid / user_name / scope claims) or the X-Tenant-Id / X-User-Id headers.
RequestIdentity resolveIdentity(string authorizationHeader, string tenantHeader,
    string userHeader, string defaultTenant) {
  RequestIdentity identity;

  if (authorizationHeader.startsWith("Bearer ")) {
    auto claims = decodeJwtClaims(authorizationHeader["Bearer ".length .. $].strip);
    if (claims.type == Json.Type.object) {
      identity.fromToken = true;
      identity.tenantId = TenantId(claims.fieldString("zid"));
      identity.userName = claims.fieldString("user_name");
      identity.userId = UserId(claims.fieldString("user_id", identity.userName));
      identity.scopes = claims.fieldStrings("scope");
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

  // {"zid":"tenant-a","user_name":"jane","scope":["auditlog.Read"]}
  auto payload = Base64URLNoPadding.encode(cast(const(ubyte)[]) `{"zid":"tenant-a","user_name":"jane","scope":["auditlog.Read"]}`);
  auto token = "eyJhbGciOiJub25lIn0." ~ payload.idup ~ ".sig";

  auto fromToken = resolveIdentity("Bearer " ~ token, "", "", "default");
  assert(fromToken.fromToken);
  assert(fromToken.tenantId.value == "tenant-a");
  assert(fromToken.userName == "jane");
  assert(fromToken.scopes == ["auditlog.Read"]);

  auto fromHeader = resolveIdentity("", "t2", "bob", "default");
  assert(!fromHeader.fromToken);
  assert(fromHeader.tenantId.value == "t2");
  assert(fromHeader.userId.value == "bob");

  assert(resolveIdentity("", "", "", "default").tenantId.value == "default");
}
