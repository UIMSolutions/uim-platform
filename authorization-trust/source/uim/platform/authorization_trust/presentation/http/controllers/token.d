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
  private void handleToken(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      string grantType;
      string clientId;
      string clientSecret;
      string scopeStr;

      // Accept both application/json and application/x-www-form-urlencoded
      auto ct = req.contentType;
      if (ct.length > 0 && ct == "application/json") {
        auto j = req.json;
        grantType    = j.getString("grant_type");
        clientId     = j.getString("client_id");
        clientSecret = j.getString("client_secret");
        scopeStr     = j.getString("scope");
      } else {
        // Form body parsed into req.params by vibe.d for form-encoded requests
        grantType    = req.params.get("grant_type", "");
        clientId     = req.params.get("client_id", "");
        clientSecret = req.params.get("client_secret", "");
        scopeStr     = req.params.get("scope", "");
      }

      if (grantType != "client_credentials") {
        writeError(res, 400, "Unsupported grant_type. Only client_credentials is supported.");
        return;
      }

      if (clientId.length == 0 || clientSecret.length == 0) {
        writeError(res, 400, "client_id and client_secret are required");
        return;
      }

      auto grantedScopes = tokenService.validateClientCredentials(clientId, clientSecret);
      if (grantedScopes.length == 0) {
        writeError(res, 401, "Invalid client credentials");
        return;
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

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
