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

class BindingController : PlatformController {
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
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.permission = j.getString("permission");
      r.allowedNamespaces = getStringArray(j, "allowedNamespaces");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = j.getString("createdBy");

      auto result = uc.create(r);

      // Return binding credentials (only shown once at creation)
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("name", result.name)
        .set("clientId", result.clientId)
        .set("clientSecret", result.clientSecret)
        .set("permission", result.permission)
        .set("status", result.status)
        .set("allowedNamespaces", toJsonArray(result.allowedNamespaces))
        .set("createdAt", result.createdAt)
        .set("expiresAt", result.expiresAt);

      res.writeJsonBody(resp, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto bindings = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (b; bindings) {
        jarr ~= Json.emptyObject
          .set("id", b.id)
          .set("name", b.name)
          .set("clientId", b.clientId)
          .set("createdAt", b.createdAt);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", bindings.length)
        .set("message", "Service bindings retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto b = uc.getById(id);

      if (b.isNull) {
        writeError(res, 404, "Service binding not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", b.id)
        .set("name", b.name)
        .set("description", b.description)
        .set("clientId", b.clientId)
        .set("allowedNamespaces", b.allowedNamespaces)
        .set("createdAt", b.createdAt)
        .set("expiresAt", b.expiresAt);
      // Note: clientSecret is NOT returned on GET (only on creation)
      res.writeJsonBody(response, 200);
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
      r.description = j.getString("description");
      r.permission = j.getString("permission");
      r.status = j.getString("status");
      r.allowedNamespaces = getStringArray(j, "allowedNamespaces");

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Service binding updated successfully");
          
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
      uc.removeById(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
