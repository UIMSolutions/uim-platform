/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.scope_controller;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ScopeController : PlatformController {
  private ManageScopesUseCase usecase;

  this(ManageScopesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/scopes",    &handleCreate);
    router.get("/api/v1/scopes",     &handleList);
    router.get("/api/v1/scopes/*",   &handleGet);
    router.put("/api/v1/scopes/*",   &handleUpdate);
    router.delete_("/api/v1/scopes/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateScopeRequest r;
      r.tenantId = tenantId;
      r.name        = j.getString("name");
      r.description = j.getString("description");
      r.appId       = j.getString("appId");

      auto result = usecase.createScope(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto scopes = usecase.listScopes(tenantId);
      auto jarr = Json.emptyArray;
      foreach (s; scopes)
        jarr ~= s.toJson();
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", scopes.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScopeId(extractIdFromPath(req));

      auto s = usecase.getScope(tenantId, id);
      if (s.id.length == 0) {
        writeError(res, 404, "Scope not found");
        return;
      }
      res.writeJsonBody(s.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScopeId(extractIdFromPath(req));

      auto j = req.json;
      UpdateScopeRequest r;
      r.tenantId = tenantId;
      r.id          = id;
      r.description = j.getString("description");

      auto result = usecase.updateScope(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.error == "Scope not found" ? 404 : 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScopeId(extractIdFromPath(req));

      auto result = usecase.deleteScope(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id), 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
