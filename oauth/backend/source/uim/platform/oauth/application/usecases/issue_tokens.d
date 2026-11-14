/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The token endpoint: client_credentials, authorization_code (+ PKCE) and
/// refresh_token grants. Refresh tokens are rotated; replaying a used code or
/// a rotated refresh token revokes everything issued from that grant
/// (RFC 6749 §10.5, OAuth 2.0 Security BCP §4.14).
module uim.platform.oauth.application.usecases.issue_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class IssueTokensUseCase : IIssueTokens {
  protected OAuthRepositories repos;
  protected IAuthenticateClients authentication;
  protected ITokenSigner signer;
  protected ISecretGenerator secrets;
  protected string issuer;

  this(OAuthRepositories repos, IAuthenticateClients authentication, ITokenSigner signer, ISecretGenerator secrets, string issuer) {
    this.repos = repos;
    this.authentication = authentication;
    this.signer = signer;
    this.secrets = secrets;
    this.issuer = issuer;
  }

  TokenResponse exchange(TokenRequest r) {
    if (r.grantType.length == 0)
      protocolError(OAuthError.invalidRequest, "grant_type is required");
    GrantType grant;
    try
      grant = parseDomainEnum!GrantType(r.grantType, "grant_type");
    catch (OAuthException)
      protocolError(OAuthError.unsupportedGrantType, "Unsupported grant_type '" ~ r.grantType ~ "'");

    auto client = authentication.authenticate(r.tenantId, r.clientId, r.clientSecret);
    if (!client.allowsGrant(grant))
      protocolError(OAuthError.unauthorizedClient, "Client may not use the " ~ cast(string) grant ~ " grant");

    final switch (grant) {
    case GrantType.clientCredentials:
      if (!client.isConfidential)
        protocolError(OAuthError.unauthorizedClient, "client_credentials needs a confidential client");
      auto scopes = grantScopes(parseScopeList(r.scope_), client.allowedScopes, activeScopeNames(repos.scopes, r.tenantId));
      RefreshToken none;
      return issue(client, "", scopes, grant, false, "", none); // no refresh token (RFC 6749 §4.4.3)
    case GrantType.authorizationCode:
      return redeemCode(client, r);
    case GrantType.refreshToken:
      return refresh(client, r);
    }
  }

  protected TokenResponse redeemCode(OAuthClient client, TokenRequest r) {
    if (r.code.length == 0)
      protocolError(OAuthError.invalidRequest, "code is required");
    auto now = nowStdTime();
    auto rec = repos.codes.findByHash(r.tenantId, fingerprint(r.code));
    if (rec.isNull || rec.clientId != client.clientId)
      protocolError(OAuthError.invalidGrant, "Invalid authorization code");
    if (rec.status == AuthCodeStatus.used) {
      revokeIssuedWith(rec);
      rec.status = AuthCodeStatus.revoked;
      repos.codes.save(rec);
      protocolError(OAuthError.invalidGrant, "Authorization code was already used; tokens issued with it are revoked");
    }
    if (!rec.isRedeemable(now))
      protocolError(OAuthError.invalidGrant, "Authorization code is " ~ cast(string) rec.effectiveStatus(now));

    auto redirectOk = r.redirectUri.length > 0 ? r.redirectUri == rec.redirectUri
      : client.redirectUris.length == 1 && client.redirectUris[0] == rec.redirectUri;
    if (!redirectOk)
      protocolError(OAuthError.invalidGrant, "redirect_uri does not match the authorization request");
    if (rec.codeChallengeMethod != CodeChallengeMethod.none) {
      if (r.codeVerifier.length == 0)
        protocolError(OAuthError.invalidRequest, "code_verifier is required");
      if (!verifyPkce(rec.codeChallengeMethod, rec.codeChallenge, r.codeVerifier))
        protocolError(OAuthError.invalidGrant, "PKCE verification failed");
    } else if (r.codeVerifier.length > 0)
      protocolError(OAuthError.invalidGrant, "code_verifier sent, but the authorization request had no code_challenge");

    rec.markUsed(now);
    repos.codes.save(rec);
    RefreshToken none;
    return issue(client, rec.userId, rec.scopes, GrantType.authorizationCode, client.issuesRefreshTokens, rec.id.value, none);
  }

  protected TokenResponse refresh(OAuthClient client, TokenRequest r) {
    if (r.refreshToken.length == 0)
      protocolError(OAuthError.invalidRequest, "refresh_token is required");
    auto now = nowStdTime();
    auto rt = repos.refreshTokens.findByHash(r.tenantId, fingerprint(r.refreshToken));
    if (rt.isNull || rt.clientId != client.clientId)
      protocolError(OAuthError.invalidGrant, "Invalid refresh token");
    if (rt.wasRotated) {
      revokeGrantFamily(r.tenantId, rt.clientId, rt.userId, now);
      protocolError(OAuthError.invalidGrant, "Refresh token was already used; all tokens of this grant are revoked");
    }
    if (!rt.isUsable(now))
      protocolError(OAuthError.invalidGrant, "Refresh token is " ~ cast(string) rt.effectiveStatus(now));
    auto scopes = refreshScopes(parseScopeList(r.scope_), rt.scopes);
    return issue(client, rt.userId, scopes, GrantType.refreshToken, true, "", rt);
  }

  /// Create, sign and store an access token (+ rotated refresh token).
  protected TokenResponse issue(OAuthClient client, string userId, string[] scopes, GrantType grant, bool withRefresh,
    string codeId, RefreshToken previous) {
    auto actor = UserId(userId.length > 0 ? userId : client.clientId);
    AccessToken at;
    stampCreated!(AccessToken, AccessTokenId)(at, client.tenantId, actor, "");
    at.clientId = client.clientId;
    at.userId = userId;
    at.scopes = scopes;
    at.grantType = grant;
    at.issuedAt = at.createdAt;
    at.expiresAt = expiryAfter(at.issuedAt, client.accessTokenValidity);
    at.authorizationCodeId = codeId;
    auto jwt = signer.sign(accessTokenClaims(at, issuer));
    at.tokenHash = fingerprint(jwt);

    string refreshValue;
    if (withRefresh) {
      RefreshToken rt;
      stampCreated!(RefreshToken, RefreshTokenId)(rt, client.tenantId, actor, "");
      refreshValue = secrets.generate(32);
      rt.tokenHash = fingerprint(refreshValue);
      rt.clientId = client.clientId;
      rt.userId = userId;
      rt.accessTokenId = at.id.value;
      rt.issuedAt = rt.createdAt;
      if (previous.isNull) {
        rt.scopes = scopes;
        rt.expiresAt = expiryAfter(rt.issuedAt, client.refreshTokenValidity);
      } else { // rotation keeps the original scope ceiling and absolute lifetime
        rt.scopes = previous.scopes;
        rt.expiresAt = previous.expiresAt;
        previous.revoke(RevocationReason.rotated, rt.issuedAt);
        previous.replacedById = rt.id.value;
        repos.refreshTokens.save(previous);
      }
      at.refreshTokenId = rt.id.value;
      repos.refreshTokens.save(rt);
    }
    repos.accessTokens.save(at);
    return TokenResponse(jwt, "bearer", client.accessTokenValidity, refreshValue, scopes, at);
  }

  /// Code replay: revoke the tokens obtained with the code and their refresh tokens.
  protected void revokeIssuedWith(const AuthorizationCode code) {
    auto now = nowStdTime();
    foreach (at; repos.accessTokens.findByAuthorizationCode(code.tenantId, code.id.value)) {
      if (at.refreshTokenId.length > 0)
        revokeRefreshChain(code.tenantId, RefreshTokenId(at.refreshTokenId), now);
      if (at.revoke(RevocationReason.replayDetected, now))
        repos.accessTokens.save(at);
    }
  }

  protected void revokeRefreshChain(TenantId t, RefreshTokenId id, long now) {
    for (size_t guard; !id.isNull && guard < 10_000; guard++) {
      auto rt = repos.refreshTokens.findById(t, id);
      if (rt.isNull)
        break;
      if (rt.revoke(RevocationReason.replayDetected, now))
        repos.refreshTokens.save(rt);
      foreach (at; repos.accessTokens.findByRefreshToken(t, rt.id.value))
        if (at.revoke(RevocationReason.replayDetected, now))
          repos.accessTokens.save(at);
      id = RefreshTokenId(rt.replacedById);
    }
  }

  /// Refresh token replay: revoke all live tokens of the client for that user.
  protected void revokeGrantFamily(TenantId t, string clientId, string userId, long now) {
    foreach (rt; repos.refreshTokens.findByClient(t, clientId))
      if (rt.userId == userId && rt.revoke(RevocationReason.replayDetected, now))
        repos.refreshTokens.save(rt);
    foreach (at; repos.accessTokens.findByClient(t, clientId))
      if (at.userId == userId && at.revoke(RevocationReason.replayDetected, now))
        repos.accessTokens.save(at);
  }
}
