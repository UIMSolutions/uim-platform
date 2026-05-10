/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.scope;

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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateScopeRequest r;
      r.name        = j.getString("name");
      r.description = j.getString("description");
      r.appId       = j.getString("appId");

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
      auto scopes = usecase.listAll();
      auto jarr = Json.emptyArray;
      foreach (s; scopes)
        jarr ~= scopeToJson(s);
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", scopes.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto s = usecase.getById(id);
      if (s.id.length == 0) {
        writeError(res, 404, "Scope not found");
        return;
      }
      res.writeJsonBody(scopeToJson(s), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto j = req.json;
      UpdateScopeRequest r;
      r.id          = id;
      r.description = j.getString("description");

      auto result = usecase.update(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.error == "Scope not found" ? 404 : 400, result.error);
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

  private Json scopeToJson(ScopeEntity s) @safe {
    return Json.emptyObject
      .set("id",          s.id)
      .set("name",        s.name)
      .set("description", s.description)
      .set("appId",       s.appId)
      .set("createdAt",   s.createdAt)
      .set("updatedAt",   s.updatedAt);
  }
}
