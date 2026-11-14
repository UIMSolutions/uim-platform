/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.authorize;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthorizeUseCase : IAuthorize {
  protected OAuthRepositories repos;
  protected ISecretGenerator secrets;
  protected long codeValiditySeconds;

  this(OAuthRepositories repos, ISecretGenerator secrets, long codeValiditySeconds = 300) {
    this.repos = repos;
    this.secrets = secrets;
    this.codeValiditySeconds = codeValiditySeconds;
  }

  string redirectUriFor(AuthorizeRequest r) {
    return clientAndRedirect(r).redirectUri;
  }

  AuthorizationGrant authorize(AuthorizeRequest r) {
    // 1. client and redirect URI — failures here must NOT be redirected (RFC 6749 §4.1.2.1)
    auto target = clientAndRedirect(r);
    auto client = target.client;
    auto redirectUri = target.redirectUri;

    // 2. everything else is reported to the client via the redirect URI
    if (r.responseType != "code")
      protocolError(OAuthError.unsupportedResponseType, "Only response_type=code is supported");
    if (!client.isActive)
      protocolError(OAuthError.unauthorizedClient, "Client is " ~ cast(string) client.status);
    if (!client.allowsGrant(GrantType.authorizationCode))
      protocolError(OAuthError.unauthorizedClient, "Client may not use the authorization_code grant");
    if (r.userId.length == 0)
      protocolError(OAuthError.loginRequired, "The user is not authenticated");

    auto method = CodeChallengeMethod.none;
    if (r.codeChallenge.length > 0) {
      if (r.codeChallengeMethod.length == 0 || r.codeChallengeMethod == "plain")
        method = CodeChallengeMethod.plain; // RFC 7636 §4.3 default
      else if (r.codeChallengeMethod == "S256")
        method = CodeChallengeMethod.s256;
      else
        protocolError(OAuthError.invalidRequest, "code_challenge_method must be S256 or plain");
      if (!isValidCodeVerifier(r.codeChallenge)) // same alphabet and length as the verifier
        protocolError(OAuthError.invalidRequest, "code_challenge must be 43-128 characters [A-Za-z0-9-._~]");
    } else if (r.codeChallengeMethod.length > 0)
      protocolError(OAuthError.invalidRequest, "code_challenge_method without code_challenge");
    if (!client.isConfidential && method == CodeChallengeMethod.none)
      protocolError(OAuthError.invalidRequest, "Public clients must use PKCE (code_challenge)");

    auto scopes = grantScopes(parseScopeList(r.scope_), client.allowedScopes, activeScopeNames(repos.scopes, r.tenantId));

    auto code = secrets.generate(32);
    AuthorizationCode rec;
    stampCreated!(AuthorizationCode, AuthorizationCodeId)(rec, r.tenantId, UserId(r.userId), "");
    rec.codeHash = fingerprint(code);
    rec.clientId = client.clientId;
    rec.userId = r.userId;
    rec.redirectUri = redirectUri;
    rec.scopes = scopes;
    rec.codeChallenge = r.codeChallenge;
    rec.codeChallengeMethod = method;
    rec.issuedAt = rec.createdAt;
    rec.expiresAt = expiryAfter(rec.issuedAt, codeValiditySeconds);
    repos.codes.save(rec);
    return AuthorizationGrant(code, redirectUri, r.state, rec);
  }

  protected struct Target {
    OAuthClient client;
    string redirectUri;
  }

  protected Target clientAndRedirect(AuthorizeRequest r) {
    if (r.clientId.length == 0)
      throw OAuthException.invalid("client_id is required");
    auto client = repos.clients.findByClientId(r.tenantId, r.clientId);
    if (client.isNull)
      throw OAuthException.invalid("Unknown client '" ~ r.clientId ~ "'");
    string redirectUri = r.redirectUri;
    if (redirectUri.length == 0) {
      if (client.redirectUris.length != 1)
        throw OAuthException.invalid("redirect_uri is required (the client has " ~ countOf(client.redirectUris.length,
            "registered redirect URI") ~ ")");
      redirectUri = client.redirectUris[0];
    } else if (!client.allowsRedirect(redirectUri))
      throw OAuthException.invalid("redirect_uri is not registered for client '" ~ client.clientId ~ "'");
    return Target(client, redirectUri);
  }
}
