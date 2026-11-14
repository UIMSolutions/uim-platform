/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for issued tokens (metadata only — token values are never stored):
///   GET {api}/tokens[?user=]   GET/DELETE {api}/tokens/:id   POST {api}/tokens/purge
module uim.platform.identity_authentication.presentation.http.controllers.tokens;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class TokenController : IdentityHttpController {
  protected ITokenUseCase tokens;

  this(ITokenUseCase tokens, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "tokens", defaultTenant, verifier);
    this.tokens = tokens;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/purge", &purge);
    router.get(basePath, &list);
    router.get(basePath ~ "/:id", &get);
    router.delete_(basePath ~ "/:id", &revoke);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto t = identity(req).tenantId;
      auto user = query(req, "user");
      replyList(res, user.length ? tokens.listByUser(t, UserId(user)) : tokens.listTokens(t), "Tokens");
    });
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, tokens.getToken(identity(req).tenantId, TokenId(id)), "Token", id);
    });
  }

  void revoke(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, tokens.revokeToken(identity(req).tenantId, TokenId(param(req, "id")))));
  }

  void purge(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, tokens.purgeExpired(identity(req).tenantId)));
  }
}
