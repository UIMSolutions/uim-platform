/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.controllers.service_binding;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.object_store.application.usecases.manage.service_bindings;
import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.service_binding;
import uim.platform.object_store.presentation.http.json_utils;

class ServiceBindingController {
  private ManageServiceBindingsUseCase uc;

  this(ManageServiceBindingsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/service-bindings", &handleCreate);
    router.get("/api/v1/buckets/*/service-bindings", &handleListByBucket);
    router.get("/api/v1/service-bindings/*", &handleGetById);
    router.post("/api/v1/service-bindings/*/revoke", &handleRevoke);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateServiceBindingRequest();
      r.tenantId = req.getTenantId;
      r.bucketId = j.getString("bucketId");
      r.name = j.getString("name");
      r.permission = j.getString("permission");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createBinding(r);
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

  private void handleListByBucket(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto bucketId = extractBucketIdFromBindingsPath(req.requestURI);
      auto bindings = uc.listBindings(bucketId);

      auto arr = Json.emptyArray;
      foreach (b; bindings)
        arr ~= serializeBinding(b);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(bindings.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      if (id == "revoke")
        return;

      auto binding = uc.getBinding(id);
      if (binding is null || binding.id.isEmpty) {
        writeError(res, 404, "Service binding not found");
        return;
      }
      res.writeJsonBody(serializeBinding(binding), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // /api/v1/service-bindings/{id}/revoke
      auto path = req.requestURI;
      // import std.string : indexOf;
      auto bindingsPos = path.indexOf("service-bindings/");
      if (bindingsPos < 0) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto start = bindingsPos + 17; // length of "service-bindings/"
      auto rest = path[start .. $];
      auto slashPos = rest.indexOf('/');
      auto id = slashPos > 0 ? rest[0 .. slashPos] : rest;

      auto result = uc.revokeBinding(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["revoked"] = Json(true);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteBinding(id);
      if (result.success) {
        auto response = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeBinding(ServiceBinding b) {
    auto j = Json.emptyObject;
    j["id"] = Json(b.id);
    j["tenantId"] = Json(b.tenantId);
    j["name"] = Json(b.name);
    j["bucketId"] = Json(b.bucketId);
    j["accessKeyId"] = Json(b.accessKeyId);
    // Never return the secret hash
    j["permission"] = Json(b.permission.to!string);
    j["status"] = Json(b.status.to!string);
    j["expiresAt"] = Json(b.expiresAt);
    j["createdBy"] = Json(b.createdBy);
    j["createdAt"] = Json(b.createdAt);
    return j;
  }

  private static string extractBucketIdFromBindingsPath(string uri) {
    // import std.string : indexOf;
    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    auto bucketsPos = path.indexOf("buckets/");
    if (bucketsPos < 0)
      return "";
    auto start = bucketsPos + 8;
    auto rest = path[start .. $];
    auto slashPos = rest.indexOf('/');
    if (slashPos > 0)
      return rest[0 .. slashPos];
    return rest;
  }
}
