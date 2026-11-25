/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Token issuing adapter: HS256 signed JWTs with XSUAA compatible claims
/// (sub, user_id, user_name, zid, scope[], iss, iat, exp, jti), verified by
/// the same Hs256TokenVerifier that protects the REST and OData endpoints.
module uim.platform.integration_automation.infrastructure.security.tokens;

import uim.platform.service.infrastructure.security.context : Hs256TokenVerifier;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class Hs256TokenIssuer : ITokenIssuer {
  protected Hs256TokenVerifier signer;
  protected long ttlSeconds;
  protected string issuer;

  this(Hs256TokenVerifier signer, long ttlSeconds, string issuer) {
    this.signer = signer;
    this.ttlSeconds = ttlSeconds;
    this.issuer = issuer;
  }

  IssuedToken issue(TenantId t, const UserAccount user, const string[] scopes) @trusted {
    auto now = Clock.currTime(UTC()).toUnixTime;
    auto claims = Json.emptyObject;
    claims["iss"] = issuer;
    claims["sub"] = user.id.value;
    claims["user_id"] = user.id.value;
    claims["user_name"] = user.displayName.length ? user.displayName : user.id.value;
    claims["zid"] = t.value;
    auto s = Json.emptyArray;
    foreach (x; scopes)
      s ~= Json(x);
    claims["scope"] = s;
    claims["iat"] = now;
    claims["exp"] = now + ttlSeconds;
    claims["jti"] = newResourceId();
    IssuedToken token;
    token.accessToken = signer.sign(claims);
    token.expiresIn = ttlSeconds;
    token.expiresAt = now + ttlSeconds;
    return token;
  }
}

///
unittest {
  auto verifier = new Hs256TokenVerifier("0123456789abcdef0123456789abcdef");
  auto issuer = new Hs256TokenIssuer(verifier, 600, "test");
  UserAccount u;
  u.id = UserAccountId("ada");
  auto token = issuer.issue(TenantId("t1"), u, ["Read", "Manage"]);
  Json claims;
  assert(verifier.verify(token.accessToken, claims) && token.expiresIn == 600);
  assert(claims["zid"].get!string == "t1" && claims["scope"].length == 2 && claims["sub"].get!string == "ada");
  auto ctx = resolveRequestContext("Bearer " ~ token.accessToken, "", "", "default", verifier);
  assert(ctx.authenticated && ctx.tenantId == "t1" && ctx.userId == "ada" && ctx.hasScope("Manage"));
}
