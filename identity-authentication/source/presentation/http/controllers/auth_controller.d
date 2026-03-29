module presentation.http.auth_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.identity_authentication.application.use_cases.authenticate_user;
import uim.platform.identity_authentication.application.use_cases.issue_token;
import uim.platform.identity_authentication.application.dto;
import presentation.http.json_utils;

/// HTTP controller for authentication endpoints.
class AuthController
{
    private AuthenticateUserUseCase authUseCase;
    private IssueTokenUseCase tokenUseCase;

    this(AuthenticateUserUseCase authUseCase, IssueTokenUseCase tokenUseCase)
    {
        this.authUseCase = authUseCase;
        this.tokenUseCase = tokenUseCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/auth/login", &handleLogin);
        router.post("/api/v1/auth/token", &handleToken);
        router.get("/api/v1/auth/health", &handleHealth);
    }

    private void handleLogin(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto authReq = AuthRequest(
                jsonStr(j, "tenantId"),
                jsonStr(j, "applicationId"),
                jsonStr(j, "email"),
                jsonStr(j, "password"),
                jsonStr(j, "mfaCode"),
                req.peer,
                req.headers.get("User-Agent", "")
            );

            auto result = authUseCase.execute(authReq);
            auto response = Json.emptyObject;
            response["success"] = Json(result.success);
            response["message"] = Json(result.message);

            if (result.mfaRequired)
            {
                import std.conv : to;
                response["mfaRequired"] = Json(true);
                response["mfaType"] = Json(result.mfaType.to!string);
            }

            if (result.success)
            {
                response["sessionId"] = Json(result.sessionId);
                response["userId"] = Json(result.userId);
            }

            res.writeJsonBody(response, result.success ? 200 : 401);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleToken(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto tokenReq = TokenRequest(
                jsonStr(j, "sessionId"),
                jsonStr(j, "clientId"),
                jsonStr(j, "clientSecret"),
                jsonStrArray(j, "scopes")
            );

            auto result = tokenUseCase.execute(tokenReq);
            auto response = Json.emptyObject;

            if (result.isSuccess())
            {
                response["access_token"] = Json(result.accessToken);
                response["refresh_token"] = Json(result.refreshToken);
                response["id_token"] = Json(result.idToken);
                response["token_type"] = Json("Bearer");
                response["expires_in"] = Json(3600L);
                res.writeJsonBody(response, 200);
            }
            else
            {
                response["error"] = Json(result.error);
                res.writeJsonBody(response, 400);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        auto response = Json.emptyObject;
        response["status"] = Json("healthy");
        response["service"] = Json("identity-authentication");
        res.writeJsonBody(response, 200);
    }
}
