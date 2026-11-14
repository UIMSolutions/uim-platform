/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.security.jwt;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// JSON Web Tokens (RFC 7519) signed with HMAC-SHA256 (HS256).
///
/// Only "HS256" is accepted on verification (no "alg": "none" downgrade).
/// For multi-service landscapes switch to an asymmetric algorithm (RS256 /
/// ES256) and publish the key set — the ITokenService port stays the same.
class JwtTokenService : ITokenService {
  protected immutable(ubyte)[] key;
  protected string headerPart;

  this(string signingSecret) {
    this.key = cast(immutable(ubyte)[]) signingSecret.idup;
    this.headerPart = base64Url(cast(const(ubyte)[]) `{"alg":"HS256","typ":"JWT"}`);
  }

  string sign(const TokenClaims c) {
    auto payload = Json.emptyObject
      .set("iss", c.issuer)
      .set("sub", c.subject)
      .set("aud", c.audience)
      .set("zid", c.tenantId.value)
      .set("sid", c.sessionId.value)
      .set("jti", c.tokenId)
      .set("typ", enumValue(c.tokenType))
      .set("user_name", c.userName)
      .set("email", c.email)
      .set("name", c.name)
      .set("scope", c.scopes.map!(s => Json(s)).array.toJson)
      .set("groups", c.groups.map!(s => Json(s)).array.toJson)
      .set("iat", toUnixSeconds(c.issuedAt))
      .set("exp", toUnixSeconds(c.expiresAt));
    auto signingInput = headerPart ~ "." ~ base64Url(cast(const(ubyte)[]) payload.toString);
    return signingInput ~ "." ~ signature(signingInput);
  }

  bool verify(string token, long now, out TokenClaims c) {
    auto parts = token.strip.split(".");
    if (parts.length != 3)
      return false;
    try {
      auto header = parseJsonString(cast(string) fromBase64Url(parts[0]).idup);
      if (header.type != Json.Type.object || fieldString(header, "alg") != "HS256")
        return false;
      if (!constantTimeEquals(signature(parts[0] ~ "." ~ parts[1]), parts[2]))
        return false;

      auto p = parseJsonString(cast(string) fromBase64Url(parts[1]).idup);
      if (p.type != Json.Type.object)
        return false;
      auto exp = fieldLong(p, "exp");
      if (exp <= 0 || exp <= toUnixSeconds(now))
        return false;

      c.issuer = fieldString(p, "iss");
      c.subject = fieldString(p, "sub");
      c.audience = fieldString(p, "aud");
      c.tenantId = TenantId(fieldString(p, "zid"));
      c.sessionId = SessionId(fieldString(p, "sid"));
      c.tokenId = fieldString(p, "jti");
      c.tokenType = parseEnum!TokenType(fieldString(p, "typ"), TokenType.access);
      c.userName = fieldString(p, "user_name");
      c.email = fieldString(p, "email");
      c.name = fieldString(p, "name");
      c.scopes = fieldStrings(p, "scope");
      c.groups = fieldStrings(p, "groups");
      c.issuedAt = fromUnixSeconds(fieldLong(p, "iat"));
      c.expiresAt = fromUnixSeconds(exp);
      return true;
    } catch (Exception) {
      return false;
    }
  }

  string generateSamlAssertion(const IAUser user, const Application app, string issuer, long now, long notOnOrAfter) {
    // Unsigned assertion skeleton — sign with XML-DSig before sending it to a service provider.
    return `<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_` ~ generateId
      ~ `" Version="2.0" IssueInstant="` ~ isoTime(now) ~ `">`
      ~ `<saml:Issuer>` ~ xmlText(issuer) ~ `</saml:Issuer>`
      ~ `<saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">`
      ~ xmlText(user.email) ~ `</saml:NameID></saml:Subject>`
      ~ `<saml:Conditions NotBefore="` ~ isoTime(now) ~ `" NotOnOrAfter="` ~ isoTime(notOnOrAfter) ~ `">`
      ~ `<saml:AudienceRestriction><saml:Audience>` ~ xmlText(app.samlEntityId) ~ `</saml:Audience>`
      ~ `</saml:AudienceRestriction></saml:Conditions>`
      ~ `<saml:AttributeStatement>`
      ~ `<saml:Attribute Name="first_name"><saml:AttributeValue>` ~ xmlText(user.firstName) ~ `</saml:AttributeValue></saml:Attribute>`
      ~ `<saml:Attribute Name="last_name"><saml:AttributeValue>` ~ xmlText(user.lastName) ~ `</saml:AttributeValue></saml:Attribute>`
      ~ `</saml:AttributeStatement></saml:Assertion>`;
  }

  protected string signature(string signingInput) {
    return base64Url(hmacSha256(key, cast(const(ubyte)[]) signingInput)[]);
  }

  private static string xmlText(string s) {
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
  }

  private static string isoTime(long stdTime) @trusted {
    auto t = SysTime(stdTime, UTC());
    t.fracSecs = Duration.zero;
    return t.toISOExtString;
  }
}

///
unittest {
  mixin(ShowTest!("JwtTokenService"));

  auto svc = new JwtTokenService("test-secret");
  auto now = Clock.currStdTime();
  TokenClaims c;
  c.issuer = "ias";
  c.subject = "u1";
  c.audience = "client-1";
  c.tenantId = TenantId("t1");
  c.tokenType = TokenType.refresh;
  c.scopes = ["openid", "profile"];
  c.issuedAt = now;
  c.expiresAt = now + 600_000_000L;

  auto token = svc.sign(c);
  assert(token.count('.') == 2);
  TokenClaims back;
  assert(svc.verify(token, now, back));
  assert(back.subject == "u1" && back.tenantId.value == "t1" && back.tokenType == TokenType.refresh);
  assert(back.scopes == ["openid", "profile"]);

  // tampering, wrong key, expiry and alg=none are rejected
  auto parts = token.split(".");
  TokenClaims ignored;
  assert(!svc.verify(parts[0] ~ "." ~ parts[1] ~ "x." ~ parts[2], now, ignored));
  assert(!new JwtTokenService("other").verify(token, now, ignored));
  assert(!svc.verify(token, c.expiresAt + 10_000_000L, ignored));
  auto none = base64Url(cast(const(ubyte)[]) `{"alg":"none"}`) ~ "." ~ parts[1] ~ ".";
  assert(!svc.verify(none, now, ignored));

  auto user = IAUser(TenantId("t1"));
  user.email = "a<b>@example.com";
  auto saml = svc.generateSamlAssertion(user, Application.init, "ias", now, now + 600_000_000L);
  assert(saml.canFind("a&lt;b&gt;@example.com"));
}
