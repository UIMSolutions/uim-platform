/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.keyring;

// import uim.platform.credential_store.application.usecases.manage.keyrings;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class KeyringController : PlatformController {
  private ManageKeyringsUseCase keyrings;

  this(ManageKeyringsUseCase keyrings) {
    this.keyrings = keyrings;
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
      r.tenantId = req.getTenantId;
      r.namespaceId = req.headers.get("X-Namespace-Id", j.getString("namespaceId"));
      r.name = j.getString("name");
      r.metadata = j.getString("metadata");
      r.format = j.getString("format");
      r.rotationPeriodDays = j.getInteger("rotationPeriodDays", 90);
      r.createdBy = j.getString("createdBy");

      auto result = keyrings.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Keyring created successfully");

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
      auto rings = keyrings.listByNamespace(NamespaceId(namespaceId));

      auto jarr = Json.emptyArray;
      foreach (k; rings) {
        jarr ~= Json.emptyObject
          .set("id", k.id)
          .set("name", k.name)
          .set("metadata", k.metadata)
          .set("version", k.version_);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", rings.length)
        .set("message", "Keyrings retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = CredentialId(extractIdFromPath(req.requestURI.to!string));
      auto k = keyrings.getById(id);

      if (k.isNull) {
        writeError(res, 404, "Keyring not found");
        return;
      }

      auto versions = keyrings.getVersions(k.id);

      auto varr = Json.emptyArray;
      foreach (v; versions) {
        varr ~= Json.emptyObject
          .set("id", v.id)
          .set("versionNumber", v.versionNumber)
          .set("isActive", v.isActive)
          .set("createdAt", v.createdAt);
      }
      
      auto kj = Json.emptyObject
        .set("id", k.id)
        .set("name", k.name)
        .set("metadata", k.metadata)
        .set("version", k.version_)
        .set("createdAt", k.createdAt)
        .set("updatedAt", k.updatedAt)
        .set("versions", varr);

      res.writeJsonBody(kj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRotate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RotateKeyringRequest r;
      r.keyringId = j.getString("keyringId");
      r.tenantId = req.getTenantId;

      auto result = keyrings.rotate(r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("versionId", result.id);

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
      auto keyringId = CredentialId(j.getString("keyringId"));

      auto result = keyrings.disable(keyringId);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("id", result.id);

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

      auto id = CredentialId(extractIdFromPath(req.requestURI.to!string));
      auto result = keyrings.remove(id);
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
