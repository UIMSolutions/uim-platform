/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.issue_token;
// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.entities.token;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.user;
// import uim.platform.identity_authentication.domain.ports.repositories.application;
// import uim.platform.identity_authentication.domain.ports.repositories.token;
// import uim.platform.identity_authentication.domain.ports.repositories.session;
// import uim.platform.identity_authentication.domain.ports.repositories.token_service;
// 
// 
// import core.time;
// 
// 
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: issue OAuth2/OIDC tokens after successful authentication.
class IssueTokenUseCase { // TODO: UIMUseCase {
  private UserRepository userRepo;
  private ApplicationRepository appRepo;
  private TokenRepository tokenRepo;
  private SessionRepository sessionRepo;
  private TokenService tokenSvc;

  this(UserRepository userRepo, ApplicationRepository appRepo,
      TokenRepository tokenRepo, SessionRepository sessionRepo, TokenService tokenSvc) {
    this.userRepo = userRepo;
    this.appRepo = appRepo;
    this.tokenRepo = tokenRepo;
    this.sessionRepo = sessionRepo;
    this.tokenSvc = tokenSvc;
  }

  TokenResponse execute(TokenRequest req) {
    // Validate session
    auto session = sessionRepo.findById(req.tenantId, req.sessionId);
    import uim.platform.identity_authentication.domain.entities.session : IASession;

    if (session.isNull || session.revoked)
      return TokenResponse(TenantId(""), "", "", "", "Invalid session");

    auto user = userRepo.findById(session.tenantId, session.userId);
    if (user.isNull)
      return TokenResponse(TenantId(""), "", "", "", "User not found");

    auto app = appRepo.findByClient(session.tenantId, req.clientId);
    if (app.isNull)
      return TokenResponse(TenantId(""), "", "", "", "Unknown application");

    if (app.clientSecret != req.clientSecret)
      return TokenResponse(TenantId(""), "", "", "", "Invalid client credentials");

    auto now = currentTimestamp();

    // Generate access token
    auto accessTokenValue = tokenSvc.generateToken(user, app, TokenType.access, req.scopes);
    auto accessToken = Token();
    accessToken.tenantId = session.tenantId;
    accessToken.id = randomUUID().toString();
    accessToken.userId = user.id;
    // accessToken.appId = app.id;
    accessToken.tokenType = TokenType.access;
    // accessToken.value = accessTokenValue;
    accessToken.scopes = req.scopes;
    accessToken.createdAt = now;
    accessToken.expiresAt = now + dur!"hours"(1).total!"hnsecs";
    accessToken.revoked = false;
    tokenRepo.save(accessToken);

    // Generate refresh token
    auto refreshTokenValue = tokenSvc.generateToken(user, app, TokenType.refresh, req.scopes);
    auto refreshToken = Token();
    refreshToken.id = randomUUID().toString();
    refreshToken.userId = user.id;
    refreshToken.tenantId = session.tenantId;
    // refreshToken.appId = app.id;
    refreshToken.tokenType = TokenType.refresh;
    // refreshToken.value = refreshTokenValue;
    refreshToken.scopes = req.scopes;
    refreshToken.createdAt = now;
    refreshToken.expiresAt = now + dur!"hours"(24).total!"hnsecs";
    refreshToken.revoked = false;
    tokenRepo.save(refreshToken);

    // Generate ID token (OIDC)
    auto idTokenValue = tokenSvc.generateToken(user, app, TokenType.idToken, req.scopes);

    return TokenResponse(session.tenantId, accessTokenValue, refreshTokenValue, idTokenValue, "");
  }
}

struct TokenRequest {
  TenantId tenantId;
  SessionId sessionId;
  
  string clientId;
  string clientSecret;
  string[] scopes;
}

struct TokenResponse {
  TenantId tenantId;

  string accessToken;
  string refreshToken;
  string idToken;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}
