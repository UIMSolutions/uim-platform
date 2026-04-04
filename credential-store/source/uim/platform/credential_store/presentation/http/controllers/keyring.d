/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.keyring;

// import uim.platform.credential_store.application.usecases.manage.keyrings;
// import uim.platform.credential_store.application.dto;
// import uim.platform.credential_store.presentation.http.json_utils;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class KeyringController : SAPController {
  private ManageKeyringsUseCase uc;

  this(ManageKeyringsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/keyrings", &handleCreate);
    router.get("/api/v1/keyrings", &handleList);
    router.get("/api/v1/keyrings/*", &handleGet);
    router.post("/api/v1/keyrings/rotate", &handleRotate);
    router.post("/api/v1/keyrings/disable", &handleDisable);
    router.delete_("/api/v1/keyrings/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateKeyringRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.namespaceId = req.headers.get("X-Namespace-Id", jsonStr(j, "namespaceId"));
      r.name = jsonStr(j, "name");
      r.metadata = jsonStr(j, "metadata");
      r.format = jsonStr(j, "format");
      r.rotationPeriodDays = jsonInt(j, "rotationPeriodDays", 90);
      r.createdBy = jsonStr(j, "createdBy");

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
      auto namespaceId = req.headers.get("X-Namespace-Id", req.params.get("namespaceId", ""));
      auto keyrings = uc.listByNamespace(namespaceId);

      auto jarr = Json.emptyArray;
      foreach (ref k; keyrings) {
        auto kj = Json.emptyObject;
        kj["id"] = Json(k.id);
        kj["name"] = Json(k.name);
        kj["metadata"] = Json(k.metadata);
        kj["version"] = Json(k.version_);
        jarr ~= kj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) keyrings.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto k = uc.get_(id);

      if (k.id.length == 0) {
        writeError(res, 404, "Keyring not found");
        return;
      }

      auto versions = uc.getVersions(k.id);

      auto kj = Json.emptyObject;
      kj["id"] = Json(k.id);
      kj["name"] = Json(k.name);
      kj["metadata"] = Json(k.metadata);
      kj["version"] = Json(k.version_);
      kj["createdAt"] = Json(k.createdAt);
      kj["updatedAt"] = Json(k.updatedAt);

      auto varr = Json.emptyArray;
      foreach (ref v; versions) {
        auto vj = Json.emptyObject;
        vj["id"] = Json(v.id);
        vj["versionNumber"] = Json(v.versionNumber);
        vj["isActive"] = Json(v.isActive);
        vj["createdAt"] = Json(v.createdAt);
        varr ~= vj;
      }
      kj["versions"] = varr;

      res.writeJsonBody(kj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRotate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RotateKeyringRequest r;
      r.keyringId = jsonStr(j, "keyringId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");

      auto result = uc.rotate(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["versionId"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDisable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto keyringId = jsonStr(j, "keyringId");

      auto result = uc.disable(keyringId);
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
      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
