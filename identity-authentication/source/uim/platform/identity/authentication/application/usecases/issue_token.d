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
// // import std.uuid;
// import core.time;
// // import std.datetime.systime : Clock;
// 
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: issue OAuth2/OIDC tokens after successful authentication.
class IssueTokenUseCase : UIMUseCase {
  private UserRepository userRepo;
  private ApplicationRepository appRepo;
  private TokenRepository tokenRepo;
  private SessionRepository sessionRepo;
  private TokenService tokenSvc;

  this(UserRepository userRepo, ApplicationRepository appRepo,
      TokenRepository tokenRepo, SessionRepository sessionRepo, TokenService tokenSvc)
  {
    this.userRepo = userRepo;
    this.appRepo = appRepo;
    this.tokenRepo = tokenRepo;
    this.sessionRepo = sessionRepo;
    this.tokenSvc = tokenSvc;
  }

  TokenResponse execute(TokenRequest req)
  {
    // Validate session
    auto session = sessionRepo.findById(req.sessionId);
    import uim.platform.identity_authentication.domain.entities.session : IdaSession;

    if (session == IdaSession.init || session.revoked)
      return TokenResponse("", "", "", "Invalid session");

    auto user = userRepo.findById(session.userId);
    if (user == User.init)
      return TokenResponse("", "", "", "User not found");

    auto app = appRepo.findByClientId(req.clientId);
    if (app == Application.init)
      return TokenResponse("", "", "", "Unknown application");

    if (app.clientSecret != req.clientSecret)
      return TokenResponse("", "", "", "Invalid client credentials");

    auto now = Clock.currStdTime();

    // Generate access token
    auto accessTokenValue = tokenSvc.generateToken(user, app, TokenType.access, req.scopes);
    auto accessToken = Token(randomUUID().toString(), user.id, session.tenantId,
        app.id, TokenType.access, accessTokenValue, req.scopes, now,
        now + dur!"hours"(1).total!"hnsecs", false);
    tokenRepo.save(accessToken);

    // Generate refresh token
    auto refreshTokenValue = tokenSvc.generateToken(user, app, TokenType.refresh, req.scopes);
    auto refreshToken = Token(randomUUID().toString(), user.id, session.tenantId,
        app.id, TokenType.refresh, refreshTokenValue, req.scopes, now,
        now + dur!"hours"(24).total!"hnsecs", false);
    tokenRepo.save(refreshToken);

    // Generate ID token (OIDC)
    auto idTokenValue = tokenSvc.generateToken(user, app, TokenType.idToken, req.scopes);

    return TokenResponse(accessTokenValue, refreshTokenValue, idTokenValue, "");
  }
}

struct TokenRequest {
  string sessionId;
  string clientId;
  string clientSecret;
  string[] scopes;
}

struct TokenResponse {
  string accessToken;
  string refreshToken;
  string idToken;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}
