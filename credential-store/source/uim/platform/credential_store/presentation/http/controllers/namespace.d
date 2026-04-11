/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.namespace;

// import uim.platform.credential_store.application.usecases.manage.namespaces;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class NamespaceController : PlatformController {
  private ManageNamespacesUseCase uc;

  this(ManageNamespacesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/namespaces", &handleCreate);
    router.get("/api/v1/namespaces", &handleList);
    router.get("/api/v1/namespaces/*", &handleGet);
    router.put("/api/v1/namespaces/*", &handleUpdate);
    router.delete_("/api/v1/namespaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateNamespaceRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.createdBy = j.getString("createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto namespaces = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ns; namespaces) {
        auto nj = Json.emptyObject;
        nj["id"] = Json(ns.id);
        nj["name"] = Json(ns.name);
        nj["description"] = Json(ns.description);
        nj["createdAt"] = Json(ns.createdAt);
        jarr ~= nj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long)namespaces.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto ns = uc.get_(id);

      if (ns.id.isEmpty) {
        writeError(res, 404, "Namespace not found");
        return;
      }

      auto nj = Json.emptyObject;
      nj["id"] = Json(ns.id);
      nj["tenantId"] = Json(ns.tenantId);
      nj["name"] = Json(ns.name);
      nj["description"] = Json(ns.description);
      nj["createdAt"] = Json(ns.createdAt);
      nj["updatedAt"] = Json(ns.updatedAt);
      nj["createdBy"] = Json(ns.createdBy);
      res.writeJsonBody(nj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateNamespaceRequest r;
      r.description = j.getString("description");

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      uc.remove(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
