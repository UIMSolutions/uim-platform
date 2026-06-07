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
      auto response = Json.emptyObject;
      response["success"] = Json(result.success);
      response["message"] = Json(result.message);

      if (result.mfaRequired) {
        

        response["mfaRequired"] = Json(true);
        response["mfaType"] = Json(result.mfaType.to!string);
      }

      if (result.hasError)
            return errorResponse(result.message, 400);
        response["sessionId"] = Json(result.sessionId);
        response["userId"] = Json(result.userId);
      }

      res.writeJsonBody(response, result.success ? 200 : 401);
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleen(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto tokenReq = TokenRequest(data.getString("sessionId"), data.getString("clientId"),
          data.getString("clientSecret"), data.getStrings("scopes"));

      auto result = tokenUseCase.execute(tokenReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["access_token"] = Json(result.accessToken);
        response["refresh_token"] = Json(result.refreshToken);
        response["id_token"] = Json(result.idToken);
        response["token_type"] = Json("Bearer");
        response["expires_in"] = Json(3600L);
        res.writeJsonBody(response, 200);
      }
      else
      {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 400);
      }
    }
    catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  protected void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto response = Json.emptyObject;
    response["status"] = Json("healthy");
    response["service"] = Json("identity-authentication");
    res.writeJsonBody(response, 200);
  }
}
