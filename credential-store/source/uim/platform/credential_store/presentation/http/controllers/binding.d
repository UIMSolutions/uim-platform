/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.binding;

// import uim.platform.credential_store.application.usecases.manage.service_bindings;
// import uim.platform.credential_store.application.dto;
// import uim.platform.credential_store.presentation.http.json_utils;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class BindingController : SAPController {
  private ManageServiceBindingsUseCase uc;

  this(ManageServiceBindingsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/bindings", &handleCreate);
    router.get("/api/v1/bindings", &handleList);
    router.get("/api/v1/bindings/*", &handleGet);
    router.put("/api/v1/bindings/*", &handleUpdate);
    router.delete_("/api/v1/bindings/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateServiceBindingRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.permission = jsonStr(j, "permission");
      r.allowedNamespaces = jsonStrArray(j, "allowedNamespaces");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = uc.create(r);

      // Return binding credentials (only shown once at creation)
      auto resp = Json.emptyObject;
      resp["id"] = Json(result.id);
      resp["name"] = Json(result.name);
      resp["clientId"] = Json(result.clientId);
      resp["clientSecret"] = Json(result.clientSecret);
      resp["permission"] = Json(result.permission);
      resp["status"] = Json(result.status);
      resp["allowedNamespaces"] = toJsonArray(result.allowedNamespaces);
      resp["createdAt"] = Json(result.createdAt);
      resp["expiresAt"] = Json(result.expiresAt);
      res.writeJsonBody(resp, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto bindings = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref b; bindings) {
        auto bj = Json.emptyObject;
        bj["id"] = Json(b.id);
        bj["name"] = Json(b.name);
        bj["clientId"] = Json(b.clientId);
        bj["createdAt"] = Json(b.createdAt);
        jarr ~= bj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) bindings.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto b = uc.get_(id);

      if (b.id.length == 0) {
        writeError(res, 404, "Service binding not found");
        return;
      }

      auto bj = Json.emptyObject;
      bj["id"] = Json(b.id);
      bj["name"] = Json(b.name);
      bj["description"] = Json(b.description);
      bj["clientId"] = Json(b.clientId);
      bj["allowedNamespaces"] = toJsonArray(b.allowedNamespaces);
      bj["createdAt"] = Json(b.createdAt);
      bj["expiresAt"] = Json(b.expiresAt);
      // Note: clientSecret is NOT returned on GET (only on creation)
      res.writeJsonBody(bj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateServiceBindingRequest r;
      r.description = jsonStr(j, "description");
      r.permission = jsonStr(j, "permission");
      r.status = jsonStr(j, "status");
      r.allowedNamespaces = jsonStrArray(j, "allowedNamespaces");

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } ) {
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
