/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of the OAuth 2.0 protocol use cases.
module uim.platform.oauth.application.dtos.token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Token endpoint request (RFC 6749 §4.1.3, §4.4.2, §6).
struct TokenRequest {
  TenantId tenantId;
  string grantType;
  string clientId;
  string clientSecret;
  string scope_; /// space separated
  string code;
  string redirectUri;
  string codeVerifier;
  string refreshToken;
}

/// Token endpoint response (RFC 6749 §5.1).
struct TokenResponse {
  string accessToken;
  string tokenType = "bearer";
  long expiresIn; /// seconds
  string refreshToken; /// "" if none was issued
  string[] scopes;
  AccessToken record;
}

/// Authorization request (RFC 6749 §4.1.1, RFC 7636 §4.3).
struct AuthorizeRequest {
  TenantId tenantId;
  string userId; /// authenticated resource owner
  string responseType;
  string clientId;
  string redirectUri; /// may be omitted if the client has exactly one
  string scope_;
  string state;
  string codeChallenge;
  string codeChallengeMethod;
}

/// The issued code and where to send it.
struct AuthorizationGrant {
  string code;
  string redirectUri;
  string state;
  AuthorizationCode record;
}

/// RFC 7662 introspection response data.
struct IntrospectionResult {
  bool active;
  string tokenType; /// access_token | refresh_token
  string clientId;
  string userId;
  string[] scopes;
  long issuedAt; /// std time
  long expiresAt; /// std time
  string jti;
  string tenantId;
  string status; /// effective status (diagnostics)
}

/// Counts of revoked / removed artefacts.
struct RevocationResult {
  size_t accessTokens;
  size_t refreshTokens;
  size_t codes;

  size_t total() const {
    return accessTokens + refreshTokens + codes;
  }

  void add(const RevocationResult other) {
    accessTokens += other.accessTokens;
    refreshTokens += other.refreshTokens;
    codes += other.codes;
  }
}
