/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the OAuth 2.0 protocol endpoints.
module uim.platform.oauth.ports.usecases.oauth_protocol;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Client authentication (RFC 6749 §2.3). Throws OAuthProtocolException(invalid_client).
interface IAuthenticateClients {
  /// Public clients pass with an empty secret; confidential clients need the right one.
  OAuthClient authenticate(TenantId tenantId, string clientId, string clientSecret);
}

/// Authorization endpoint (RFC 6749 §4.1.1, PKCE RFC 7636).
interface IAuthorize {
  /// Step 1: the registered redirect URI to answer to. Unknown clients and
  /// unregistered URIs throw OAuthException — they must NOT be redirected to.
  string redirectUriFor(AuthorizeRequest request);

  /// Step 2: issue the code. Problems throw OAuthProtocolException and are
  /// reported to the client via the redirect URI of step 1 (error=...).
  AuthorizationGrant authorize(AuthorizeRequest request);
}

/// Token endpoint (RFC 6749 §3.2).
interface IIssueTokens {
  TokenResponse exchange(TokenRequest request);
}

/// Introspection (RFC 7662) and revocation (RFC 7009).
interface IIntrospectTokens {
  IntrospectionResult introspect(TenantId tenantId, string token, string tokenTypeHint = "");
  /// Unknown tokens are not an error (RFC 7009 §2.2). If requesterClientId is
  /// set, only tokens of that client are revoked.
  RevocationResult revoke(TenantId tenantId, string token, string tokenTypeHint = "", string requesterClientId = "");
}
