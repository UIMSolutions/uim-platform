/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for corporate identity providers (delegated authentication):
///   GET/POST {api}/identity-providers   GET/PUT/PATCH/DELETE {api}/identity-providers/:id
///   GET {api}/identity-providers/resolve?email=&redirectUri=&state=
module uim.platform.identity_authentication.presentation.http.controllers.identity_providers;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class IdentityProviderController : IdentityHttpController {
  protected IManageIdentityProvidersUseCase idps;

  this(IManageIdentityProvidersUseCase idps, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "identity-providers", defaultTenant, verifier);
    this.idps = idps;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath ~ "/resolve", &resolve);
    crudRoutes(router, &list, &get, &create, &update, &remove);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, idps.listIdps(identity(req).tenantId), "Identity providers"));
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, idps.getIdp(identity(req).tenantId, IdpConfigId(id)), "Identity provider", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!IdpConfigDTO(req, res, (dto) => idps.createIdp(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(IdpConfigDTO, IdpConfig)(req, res, "Identity provider", (t, id) => idps.getIdp(t, IdpConfigId(id)),
      (dto) => idps.updateIdp(dto));
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, idps.deleteIdp(identity(req).tenantId, IdpConfigId(param(req, "id")))));
  }

  void resolve(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto idp = idps.resolveIdp(identity(req).tenantId, query(req, "email"));
      if (idp.isNull)
        return fail(res, 404, "No identity provider for '" ~ query(req, "email") ~ "' — use the local login");
      auto data = idp.toJson;
      auto redirect = query(req, "redirectUri");
      if (redirect.length)
        data["authorizationUrl"] = idps.buildAuthorizationUrl(idp, redirect, query(req, "state", generateId));
      reply(res, 200, "Identity provider resolved", data);
    });
  }
}
