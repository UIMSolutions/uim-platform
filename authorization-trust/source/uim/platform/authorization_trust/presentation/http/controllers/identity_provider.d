/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.identity_provider;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class IdentityProviderController : PlatformController {
  private ManageIdentityProvidersUseCase usecase;

  this(ManageIdentityProvidersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/identity-providers", &handleCreate);
    router.get("/api/v1/identity-providers", &handleList);
    router.get("/api/v1/identity-providers/*", &handleGet);
    router.put("/api/v1/identity-providers/*", &handleUpdate);
    router.delete_("/api/v1/identity-providers/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateIdentityProviderRequest r;
      r.tenantId = tenantId;
      r.alias_ = j.getString("alias");
      r.displayName = j.getString("displayName");
      r.idpType = j.getString("idpType");
      r.metadataUrl = j.getString("metadataUrl");
      r.entityId = j.getString("entityId");
      r.ssoUrl = j.getString("ssoUrl");
      r.sloUrl = j.getString("sloUrl");
      r.signingCert = j.getString("signingCert");
      r.isActive = j.getBool("isActive");
      r.isDefault = j.getBool("isDefault");

      auto result = usecase.createIdentityProvider(r);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("id", result.id)
            .set("message", "Identity provider created successfully"), 201);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto idps = usecase.listIdentityProviders(tenantId);
      auto jarr = Json.emptyArray;
      foreach (idp; idps)
        jarr ~= idpToJson(idp);
      res.writeJsonBody(Json.emptyObject
          .set("items", jarr)
          .set("totalCount", idps.length)
          .set("message", "Identity providers retrieved successfully"), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = IdentityProviderId(extractIdFromPath(req));

      auto idp = usecase.getIdentityProvider(tenantId, id);
      if (idp.isNull) {
        writeError(res, 404, "Identity provider not found");
        return;
      }
      res.writeJsonBody(idp.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = IdentityProviderId(extractIdFromPath(req));
      auto j = req.json;

      UpdateIdentityProviderRequest r;
      r.tenantId = tenantId;
      r.identityProviderId = id;
      r.displayName = j.getString("displayName");
      r.metadataUrl = j.getString("metadataUrl");
      r.ssoUrl = j.getString("ssoUrl");
      r.sloUrl = j.getString("sloUrl");
      r.signingCert = j.getString("signingCert");
      r.isActive = j.getBool("isActive");
      r.isDefault = j.getBool("isDefault");

      auto result = usecase.updateIdentityProvider(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject
            .set("id", result.id)
            .set("message", "Identity provider updated successfully"), 200);
      else
        writeError(res, result.errorMessage == "Identity provider not found" ? 404 : 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = IdentityProviderId(extractIdFromPath(req));

      auto result = usecase.deleteIdentityProvider(tenantId, id);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject.set("id", id)
            .set("message", "Identity provider deleted successfully"), 200);
      else
        writeError(res, 404, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
