/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Token verification for the HTTP adapters.
///   XSUAA binding (VCAP_SERVICES, RS256)  → tokens required, scopes enforced
///   requireAuthentication + jwtSecret     → HS256 tokens (tests, non-BTP setups)
///   otherwise                             → open (local development); tenant
///                                           from X-Tenant-Id, user from X-User-Id
module uim.platform.service_manager.infrastructure.security.authentication;

import vibe.http.server : HTTPServerRequest;
import uim.platform.service.infrastructure.security.context;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class SecuritySetup {
  ITokenVerifier verifier;
  bool requireAuthentication;
  string mode = "open"; /// open | hs256 | xsuaa
  string defaultTenant = "default";

  /// Resolve the caller of an HTTP request.
  RequestContext resolve(HTTPServerRequest req, string channel) {
    auto ctx = resolveRequestContext(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
      req.headers.get("X-User-Id", ""), defaultTenant, verifier);
    ctx.channel = channel;
    return ctx;
  }
}

SecuritySetup configureSecurity(ServiceManagerConfig config) @trusted {
  auto s = new SecuritySetup;
  s.defaultTenant = config.defaultTenant;
  auto uaa = serviceCredentials(config.raw, "xsuaa");
  if (uaa.isObject && "verificationkey" in uaa) {
    s.verifier = new Rs256TokenVerifier(uaa["verificationkey"].get!string);
    s.requireAuthentication = true;
    s.mode = "xsuaa";
  } else if (config.requireAuthentication) {
    enforce(config.jwtSecret.length > 0, "requireAuthentication needs an XSUAA binding or jwtSecret (HS256)");
    s.verifier = new Hs256TokenVerifier(config.jwtSecret);
    s.requireAuthentication = true;
    s.mode = "hs256";
  }
  return s;
}
