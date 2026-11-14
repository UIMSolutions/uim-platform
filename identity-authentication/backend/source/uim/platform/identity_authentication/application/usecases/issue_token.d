/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.issue_token;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// OAuth 2.0 / OIDC token lifecycle: issue (session → tokens), refresh with
/// rotation, introspection, revocation, userinfo and token administration.
///
/// Tokens are signed JWTs; the store only keeps a SHA-256 fingerprint of each
/// value, so revocation and introspection work without storing bearer secrets.
class IssueTokenUseCase : ITokenUseCase {
  protected IUserRepository users;
  protected IGroupRepository groups;
  protected IApplicationRepository applications;
  protected ITokenRepository tokens;
  protected ISessionRepository sessions;
  protected IPolicyRepository policies;
  protected ITokenService signer;
  protected ISecretService secrets;
  protected IIdentityEventPublisher events;
  protected AuthenticationSettings settings;

  this(IUserRepository users, IGroupRepository groups, IApplicationRepository applications,
      ITokenRepository tokens, ISessionRepository sessions, IPolicyRepository policies,
      ITokenService signer, ISecretService secrets, IIdentityEventPublisher events = null,
      AuthenticationSettings settings = AuthenticationSettings.init) {
    this.users = users;
    this.groups = groups;
    this.applications = applications;
    this.tokens = tokens;
    this.sessions = sessions;
    this.policies = policies;
    this.signer = signer;
    this.secrets = secrets;
    this.events = events is null ? new NullEventPublisher : events;
    this.settings = settings;
  }

  // ── grants ─────────────────────────────────────────────────────────────

  TokenResponse issueTokens(TokenRequest req) {
    auto now = nowStdTime();
    auto session = sessions.findById(req.tenantId, req.sessionId);
    if (session.isNull || !session.isActive(now))
      return TokenResponse.failure("invalid_grant", "Session is unknown, expired or revoked");

    Application app;
    auto clientError = authenticateClient(req.tenantId, req.clientId, req.clientSecret, app);
    if (clientError.length)
      return TokenResponse.failure("invalid_client", clientError, 401);

    auto user = users.findById(session.tenantId, session.userId);
    if (user.isNull || !user.isActive)
      return TokenResponse.failure("invalid_grant", "User is unknown or not active");

    auto scopes = cleanList(req.scopes);
    auto badScope = scopes.find!(s => !app.allowsScope(s));
    if (!badScope.empty)
      return TokenResponse.failure("invalid_scope", "Scope '" ~ badScope.front ~ "' is not allowed for this client");

    // authorization policies of the application
    PolicyEvaluationContext ctx;
    ctx.ipAddress = req.ipAddress.length ? req.ipAddress : session.ipAddress;
    ctx.authMethod = session.authMethod;
    ctx.userGroups = groupKeysOf(groups, user);
    ctx.mfaUsed = session.mfaUsed != MfaType.none;
    auto denying = findDenyingPolicies(policies.findByApplication(session.tenantId, app.id), user, ctx);
    if (denying.length)
      return TokenResponse.failure("access_denied", "Access denied by policy '" ~ denying[0].name ~ "'", 403);

    return mint(user, app, session, scopes, now, true);
  }

  TokenResponse refreshTokens(RefreshRequest req) {
    auto now = nowStdTime();
    TokenClaims claims;
    if (!signer.verify(req.refreshToken, now, claims) || claims.tokenType != TokenType.refresh)
      return TokenResponse.failure("invalid_grant", "Refresh token is invalid or expired");
    if (claims.tenantId != req.tenantId)
      return TokenResponse.failure("invalid_grant", "Refresh token belongs to another tenant");

    auto stored = tokens.findByHash(req.tenantId, secrets.fingerprint(req.refreshToken));
    if (stored.isNull || !stored.isActive(now)) {
      // Reuse of a rotated refresh token: revoke the whole session (token theft).
      if (!stored.isNull && stored.revoked && !stored.sessionId.isNull) {
        sessions.revoke(req.tenantId, stored.sessionId);
        tokens.revokeAllForSession(req.tenantId, stored.sessionId);
      }
      return TokenResponse.failure("invalid_grant", "Refresh token was revoked");
    }

    Application app;
    auto clientError = authenticateClient(req.tenantId, req.clientId, req.clientSecret, app);
    if (clientError.length)
      return TokenResponse.failure("invalid_client", clientError, 401);
    if (app.clientId != claims.audience)
      return TokenResponse.failure("invalid_grant", "Refresh token was issued to another client");

    auto session = sessions.findById(req.tenantId, stored.sessionId);
    if (session.isNull || !session.isActive(now))
      return TokenResponse.failure("invalid_grant", "Session expired or revoked");
    auto user = users.findById(req.tenantId, stored.userId);
    if (user.isNull || !user.isActive)
      return TokenResponse.failure("invalid_grant", "User is unknown or not active");

    // scopes may only be narrowed
    auto scopes = req.scopes.length ? cleanList(req.scopes) : stored.scopes.dup;
    if (scopes.any!(s => !stored.scopes.canFind(s)))
      return TokenResponse.failure("invalid_scope", "Requested scopes exceed the original grant");

    tokens.revoke(req.tenantId, stored.id); // rotation
    return mint(user, app, session, scopes, now, false);
  }

  TokenIntrospection introspect(TenantId tenantId, string token) {
    TokenIntrospection result;
    auto now = nowStdTime();
    TokenClaims claims;
    if (token.length == 0 || !signer.verify(token, now, claims) || claims.tenantId != tenantId)
      return result;
    auto stored = tokens.findByHash(tenantId, secrets.fingerprint(token));
    if (stored.isNull || !stored.isActive(now))
      return result;

    result.active = true;
    result.subject = claims.subject;
    result.clientId = claims.audience;
    result.userName = claims.userName;
    result.tenantId = claims.tenantId;
    result.tokenType = claims.tokenType;
    result.scopes = claims.scopes;
    result.issuedAt = claims.issuedAt;
    result.expiresAt = claims.expiresAt;
    return result;
  }

  UsecaseResult revoke(TenantId tenantId, string token) {
    auto stored = tokens.findByHash(tenantId, secrets.fingerprint(token));
    // RFC 7009 §2.2: unknown tokens are not an error
    if (stored.isNull)
      return succeeded("", "Token is not active");
    return revokeToken(tenantId, stored.id);
  }

  Json userInfo(TenantId tenantId, string accessToken) {
    auto info = introspect(tenantId, accessToken);
    if (!info.active || info.tokenType != TokenType.access)
      return Json(null);
    auto user = users.findById(tenantId, UserId(info.subject));
    if (user.isNull)
      return Json(null);
    auto groupNames = Json.emptyArray;
    foreach (g; user.groupIds) {
      auto group = groups.findById(tenantId, g);
      groupNames ~= Json(group.isNull ? g.value : group.name);
    }
    return Json.emptyObject
      .set("sub", user.id.value)
      .set("preferred_username", user.userName)
      .set("name", user.displayName)
      .set("given_name", user.firstName)
      .set("family_name", user.lastName)
      .set("email", user.email)
      .set("phone_number", user.phoneNumber)
      .set("groups", groupNames)
      .set("zid", tenantId.value);
  }

  // ── administration ─────────────────────────────────────────────────────

  Token[] listTokens(TenantId tenantId) {
    return tokens.findByTenant(tenantId);
  }

  Token[] listByUser(TenantId tenantId, UserId userId) {
    return tokens.findByUser(tenantId, userId);
  }

  Token getToken(TenantId tenantId, TokenId id) {
    return tokens.findById(tenantId, id);
  }

  UsecaseResult revokeToken(TenantId tenantId, TokenId id) {
    auto token = tokens.findById(tenantId, id);
    if (token.isNull)
      return notFound("Token", id.value);
    tokens.revoke(tenantId, id);
    events.publish(IdentityTopics.tokenRevoked, Json.emptyObject
        .set("tenantId", tenantId.value).set("tokenId", id.value).set("userId", token.userId.value));
    return succeeded(id.value, "Token revoked");
  }

  UsecaseResult revokeAllForUser(TenantId tenantId, UserId userId) {
    tokens.revokeAllForUser(tenantId, userId);
    return succeeded(userId.value, "All tokens of the user revoked");
  }

  UsecaseResult purgeExpired(TenantId tenantId) {
    auto removed = tokens.removeExpired(tenantId, nowStdTime());
    return succeeded("", removed.to!string ~ " expired token(s) removed", 200,
      Json.emptyObject.set("removed", removed));
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// "" if the client is known, active and the secret matches.
  protected string authenticateClient(TenantId tenantId, string clientId, string clientSecret, out Application app) {
    app = applications.findByClient(tenantId, clientId);
    if (app.isNull || !secrets.matches(clientSecret, app.clientSecretHash))
      return "Invalid client credentials";
    if (!app.active)
      return "Client is deactivated";
    return "";
  }

  protected TokenResponse mint(IAUser user, Application app, IASession session, string[] scopes, long now, bool withIdToken) {
    auto accessExp = now + settings.accessTokenMinutes * hnsecsPerMinute;
    auto refreshExp = min(now + settings.refreshTokenHours * 60 * hnsecsPerMinute,
      session.expiresAt > 0 ? session.expiresAt : long.max);

    TokenClaims base;
    base.issuer = settings.issuer;
    base.subject = user.id.value;
    base.audience = app.clientId;
    base.tenantId = user.tenantId;
    base.sessionId = session.id;
    base.userName = user.userName;
    base.email = user.email;
    base.name = user.displayName;
    base.scopes = scopes;
    base.groups = groupKeysOf(groups, user);
    base.issuedAt = now;

    string store(TokenType type, long expiresAt) {
      auto claims = base;
      claims.tokenId = generateId;
      claims.tokenType = type;
      claims.expiresAt = expiresAt;
      auto value = signer.sign(claims);

      auto t = Token(user.tenantId, TokenId(claims.tokenId), user.id);
      t.userId = user.id;
      t.applicationId = app.id;
      t.sessionId = session.id;
      t.tokenType = type;
      t.tokenHash = secrets.fingerprint(value);
      t.scopes = scopes;
      t.issuedAt = now;
      t.expiresAt = expiresAt;
      tokens.save(t);
      return value;
    }

    TokenResponse r;
    r.tenantId = user.tenantId;
    r.accessToken = store(TokenType.access, accessExp);
    r.refreshToken = store(TokenType.refresh, refreshExp);
    if (withIdToken && (scopes.length == 0 || scopes.canFind("openid")))
      r.idToken = store(TokenType.idToken, now + settings.idTokenMinutes * hnsecsPerMinute);
    r.expiresIn = settings.accessTokenMinutes * 60L;
    r.scopes = scopes;

    events.publish(IdentityTopics.tokensIssued, Json.emptyObject
        .set("tenantId", user.tenantId.value).set("userId", user.id.value)
        .set("clientId", app.clientId).set("sessionId", session.id.value));
    return r;
  }
}
