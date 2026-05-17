/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.services.token_service;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
/// Simplified JWT token service for the Authorization and Trust Management Service.
/// Issues opaque bearer tokens representing granted scopes.
/// In a production deployment this would produce signed RS256 JWT tokens.
class TokenService {
  private OAuthClientRepository clientRepo;

  this(OAuthClientRepository clientRepo) {
    this.clientRepo = clientRepo;
  }

  /// Validate client credentials and return the granted scopes.
  /// Returns empty array when credentials are invalid.
  string[] validateClientCredentials(string clientId, string clientSecret) {
    auto client = clientRepo.findByClientId(clientId);
    if (client.isNull)
      return [];
    if (client.clientSecret != hashSecret(clientSecret))
      return [];
    return client.scopes;
  }

  /// Build a minimal JWT-like access token (header.payload.signature, base64url).
  /// This simplified implementation uses HMAC-free encoding for portability.
  string buildAccessToken(string clientId, string[] scopes, int expiresInSeconds) @trusted {
    import std.format : format;
    import std.algorithm : joiner;

    long issuedAt = currentTimestamp();
    long expiresAt = issuedAt + expiresInSeconds;

    string header  = Base64.encode(cast(ubyte[]) `{"alg":"none","typ":"JWT"}`.representation).idup;
    string payload = Base64.encode(cast(ubyte[]) format(
      `{"sub":"%s","scope":"%s","iat":%d,"exp":%d}`,
      clientId,
      scopes.joiner(" ").array,
      issuedAt,
      expiresAt
    ).representation).idup;

    return header ~ "." ~ payload ~ ".";
  }

  /// One-way hash for client secret storage (SHA-256 in hex, @trusted wrapper).
  static string hashSecret(string secret) @trusted {
    import std.digest.sha : sha256Of;
    import std.digest : toHexString;
    return sha256Of(secret.representation).toHexString.idup;
  }
}
