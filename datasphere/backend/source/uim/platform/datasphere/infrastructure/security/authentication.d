/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authentication of the HTTP adapters (REST, OData, /auth).
///
///   xsuaa  an XSUAA binding in VCAP_SERVICES: RS256 tokens of the approuter
///          are required, scopes enforced; login happens in the approuter
///   jwt    built-in login: POST /auth/login checks user name and password
///          and issues HS256 tokens (jwtSecret); tokens are required, scopes
///          enforced (also selected by requireAuthentication = true)
///   open   no authentication (local development); tenant from X-Tenant-Id,
///          user from X-User-Id
module uim.platform.datasphere.infrastructure.security.authentication;

import vibe.http.server : HTTPServerRequest;
import uim.platform.service.infrastructure.security.context;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SecuritySetup {
  ITokenVerifier verifier;
  ITokenIssuer issuer; /// jwt mode only
  bool requireAuthentication;
  string mode = "open"; /// open | jwt | xsuaa
  string defaultTenant = "default";
  bool generatedSecret; /// jwt mode without configured jwtSecret (tokens die with the process)

  bool loginEnabled() const {
    return mode == "jwt" && issuer !is null;
  }

  /// Resolve the caller of an HTTP request.
  RequestContext resolve(HTTPServerRequest req, string channel) {
    auto ctx = resolveRequestContext(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
      req.headers.get("X-User-Id", ""), defaultTenant, verifier);
    ctx.channel = channel;
    return ctx;
  }

  /// True if the caller may perform an operation needing the scope.
  bool permits(const RequestContext ctx, string scope_) const {
    return !requireAuthentication || ctx.hasScope(scope_);
  }
}

SecuritySetup configureSecurity(DspConfig config) @trusted {
  auto s = new SecuritySetup;
  s.defaultTenant = config.defaultTenant;
  auto uaa = serviceCredentials(config.raw, "xsuaa");
  if (uaa.isObject && "verificationkey" in uaa) {
    s.verifier = new Rs256TokenVerifier(uaa["verificationkey"].get!string);
    s.requireAuthentication = true;
    s.mode = "xsuaa";
  } else if (config.authMode == "jwt") {
    auto secret = config.jwtSecret;
    if (secret.length == 0) {
      secret = randomToken(32);
      s.generatedSecret = true;
    }
    enforce(secret.length >= 32, "jwtSecret must have at least 32 characters");
    auto hs256 = new Hs256TokenVerifier(secret, 30);
    s.verifier = hs256;
    s.issuer = new Hs256TokenIssuer(hs256, config.tokenTtlSeconds, config.serviceName);
    s.requireAuthentication = true;
    s.mode = "jwt";
  }
  return s;
}
