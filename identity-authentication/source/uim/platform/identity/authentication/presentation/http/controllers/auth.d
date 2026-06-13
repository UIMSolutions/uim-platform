/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.auth;

// import uim.platform.identity.authentication.application.usecases.authenticate_user;
// import uim.platform.identity.authentication.application.usecases.issue_token;
// import uim.platform.identity.authentication.application.dto;
import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// HTTP controller for authentication endpoints.
class AuthController : HttpController {
  private AuthenticateUserUseCase authUseCase;
  private IssueTokenUseCase tokenUseCase;

  this(AuthenticateUserUseCase authUseCase, IssueTokenUseCase tokenUseCase) {
    this.authUseCase = authUseCase;
    this.tokenUseCase = tokenUseCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/auth/login", &handleLogin);
    router.post("/api/v1/auth/token", &handleToken);
    router.get("/api/v1/auth/health", &handleHealth);
  }

  protected void handleLogin(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto authReq = AuthRequest(data.getString("tenantId"), data.getString("applicationId"),
        data.getString("email"), data.getString("password"),
        data.getString("mfaCode"), req.peer, req.headers.get("User-Agent", ""));

      auto result = authUseCase.execute(authReq);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto response = Json.emptyObject
        .set("success", result.success)
        .set("message", result.message);

      if (result.mfaRequired) {
        response["mfaRequired"] = Json(true);
        response["mfaType"] = Json(result.mfaType.to!string);
      }

      response["sessionId"] = Json(result.sessionId);
      response["userId"] = Json(result.userId);

      return successResponse("", "", 0, response);

    }

    protected Json tokenHandler(HTTPServerRequest req) {
      auto precheck = super.postHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto tokenReq = TokenRequest(data.getString("sessionId"), data.getString("clientId"),
        data.getString("clientSecret"), data.getStrings("scopes"));

      auto result = tokenUseCase.execute(tokenReq);
      if (result.hasError())
        return errorResponse("", 0);

      auto response = Json.emptyObject
        .set("access_token", result.accessToken)
        .set("refresh_token", result.refreshToken)
        .set("id_token", result.idToken)
        .set("token_type", "Bearer")
        .set("expires_in", 3600L);

      return successResponse("", "", 0, response);
    }
  }

  protected void handleToken(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = tokenHandler(req);
      res.writeJsonBody(response, response.code);

    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
