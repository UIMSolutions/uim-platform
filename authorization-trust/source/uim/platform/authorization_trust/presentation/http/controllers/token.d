/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.token;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
/// OAuth 2.0 token endpoint.
/// Supports: client_credentials grant type (simplified, no PKCE).
class TokenController : PlatformController {
  private TokenService tokenService;

  this(TokenService tokenService) {
    this.tokenService = tokenService;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/oauth/token", &handleToken);
  }

  // POST /api/v1/oauth/token
  // Accepts form-encoded or JSON body with grant_type, client_id, client_secret, scope
  protected Json tokenHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

auto tenantId = precheck.tenantId;
      string grantType;
      string clientId;
      string clientSecret;
      string scopeStr;

      // Accept both application/json and application/x-www-form-urlencoded
      auto ct = req.contentType;
      if (ct.length > 0 && ct == "application/json") {
        auto data = precheck.data;
        grantType    = data.getString("grant_type");
        clientId     = data.getString("client_id");
        clientSecret = data.getString("client_secret");
        scopeStr     = data.getString("scope");
      } else {
        // Form body parsed into req.params by vibe.d for form-encoded requests
        grantType    = req.params.get("grant_type", "");
        clientId     = req.params.get("client_id", "");
        clientSecret = req.params.get("client_secret", "");
        scopeStr     = req.params.get("scope", "");
      }

      if (grantType != "client_credentials") {
        return errorResponse("Unsupported grant_type. Only client_credentials is supported.", 400);
      }

      if (clientId.length == 0 || clientSecret.length == 0) {
        return errorResponse("client_id and client_secret are required", 400);
      }

      auto grantedScopes = tokenService.validateClientCredentials(clientId, clientSecret);
      if (grantedScopes.length == 0) {
        return errorResponse("Invalid client credentials", 401);
      }

      int expiresIn = 3600;
      auto token = tokenService.buildAccessToken(clientId, grantedScopes, expiresIn);

      auto scopeArr = Json.emptyArray;
      foreach (s; grantedScopes)
        scopeArr ~= Json(s);

      auto resp = Json.emptyObject
        .set("access_token", token)
        .set("token_type",   "Bearer")
        .set("expires_in",   expiresIn)
        .set("scope",        scopeArr);
  
    return successResponse("Access token issued successfully", "Issued", 200, resp);
  }

  protected void handleGetToken(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = tokenHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
