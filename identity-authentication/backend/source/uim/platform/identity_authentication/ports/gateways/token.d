/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.gateways.token;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Claims carried by an issued token (JWT payload).
struct TokenClaims {
  string tokenId; /// jti
  string issuer; /// iss
  string subject; /// sub (user id)
  string audience; /// aud (client id)
  TenantId tenantId; /// zid
  SessionId sessionId; /// sid
  TokenType tokenType = TokenType.access;
  string userName;
  string email;
  string name;
  string[] scopes;
  string[] groups;
  long issuedAt; /// stdTime
  long expiresAt; /// stdTime
}

/// Driven port: token signing and verification.
interface ITokenService {
  /// Sign the claims (JWT).
  string sign(const TokenClaims claims);

  /// Verify signature and expiry at `now` (stdTime). On success fills claims.
  bool verify(string token, long now, out TokenClaims claims);

  /// A (simplified) SAML 2.0 assertion for the user and service provider.
  string generateSamlAssertion(const IAUser user, const Application app, string issuer, long now, long notOnOrAfter);
}
