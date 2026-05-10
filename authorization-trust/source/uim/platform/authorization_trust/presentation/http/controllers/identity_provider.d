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
    router.post("/api/v1/identity-providers",    &handleCreate);
    router.get("/api/v1/identity-providers",     &handleList);
    router.get("/api/v1/identity-providers/*",   &handleGet);
    router.put("/api/v1/identity-providers/*",   &handleUpdate);
    router.delete_("/api/v1/identity-providers/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateIdentityProviderRequest r;
      r.alias_       = j.getString("alias");
      r.displayName  = j.getString("displayName");
      r.idpType      = j.getString("idpType");
      r.metadataUrl  = j.getString("metadataUrl");
      r.entityId     = j.getString("entityId");
      r.ssoUrl       = j.getString("ssoUrl");
      r.sloUrl       = j.getString("sloUrl");
      r.signingCert  = j.getString("signingCert");
      r.isActive     = j.getBool("isActive");
      r.isDefault    = j.getBool("isDefault");

      auto result = usecase.create(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto idps = usecase.listAll();
      auto jarr = Json.emptyArray;
      foreach (idp; idps)
        jarr ~= idpToJson(idp);
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", idps.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto idp = usecase.getById(id);
      if (idp.id.length == 0) {
        writeError(res, 404, "Identity provider not found");
        return;
      }
      res.writeJsonBody(idpToJson(idp), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto j = req.json;
      UpdateIdentityProviderRequest r;
      r.id          = id;
      r.displayName = j.getString("displayName");
      r.metadataUrl = j.getString("metadataUrl");
      r.ssoUrl      = j.getString("ssoUrl");
      r.sloUrl      = j.getString("sloUrl");
      r.signingCert = j.getString("signingCert");
      r.isActive    = j.getBool("isActive");
      r.isDefault   = j.getBool("isDefault");

      auto result = usecase.update(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.error == "Identity provider not found" ? 404 : 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto result = usecase.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id), 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json idpToJson(IdentityProviderEntity idp) @safe {
    return Json.emptyObject
      .set("id",          idp.id)
      .set("alias",       idp.alias_)
      .set("displayName", idp.displayName)
      .set("idpType",     idpTypeToString(idp.idpType))
      .set("metadataUrl", idp.metadataUrl)
      .set("entityId",    idp.entityId)
      .set("ssoUrl",      idp.ssoUrl)
      .set("sloUrl",      idp.sloUrl)
      .set("isActive",    idp.isActive)
      .set("isDefault",   idp.isDefault)
      .set("createdAt",   idp.createdAt)
      .set("updatedAt",   idp.updatedAt);
  }
}
