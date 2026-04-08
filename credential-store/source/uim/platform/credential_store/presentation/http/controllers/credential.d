/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.credential;

// import uim.platform.credential_store.application.usecases.manage.credentials;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class CredentialController : SAPController {
  private ManageCredentialsUseCase uc;

  this(ManageCredentialsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    // Separate endpoints per credential type (SAP pattern)
    router.post("/api/v1/passwords", &handleCreatePassword);
    router.get("/api/v1/passwords", &handleListPasswords);
    router.get("/api/v1/passwords/*", &handleGetPassword);
    router.delete_("/api/v1/passwords/*", &handleDeletePassword);

    router.post("/api/v1/keys", &handleCreateKey);
    router.get("/api/v1/keys", &handleListKeys);
    router.get("/api/v1/keys/*", &handleGetKey);
    router.delete_("/api/v1/keys/*", &handleDeleteKey);
  }

  // --- Password endpoints ---

  private void handleCreatePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "password");
  }

  private void handleListPasswords(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "password");
  }

  private void handleGetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res);
  }

  private void handleDeletePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res);
  }

  // --- Key endpoints ---

  private void handleCreateKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "key");
  }

  private void handleListKeys(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "key");
  }

  private void handleGetKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res);
  }

  private void handleDeleteKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res);
  }

  // --- Shared handlers ---

  private void handleCreateCredential(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto j = req.json;
      CreateCredentialRequest r;
      r.tenantId = req.getTenantId;
      r.namespaceId = req.headers.get("X-Namespace-Id", j.getString("namespaceId"));
      r.name = j.getString("name");
      r.type = type;
      r.value = j.getString("value");
      r.metadata = j.getString("metadata");
      r.format = j.getString("format");
      r.username = j.getString("username");
      r.createdBy = j.getString("createdBy");
      r.ifNoneMatch = req.headers.get("If-None-Match", "");

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

  private void handleListCredentials(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto namespaceId = req.headers.get("X-Namespace-Id", req.params.get("namespaceId", ""));

      typeof(uc.listByType(namespaceId, type)) creds;
      if (namespaceId.length > 0) {
        creds = uc.listByType(namespaceId, type);
      }

      auto jarr = Json.emptyArray;
      foreach (ref c; creds) {
        auto cj = Json.emptyObject;
        cj["id"] = Json(c.id);
        cj["name"] = Json(c.name);
        cj["metadata"] = Json(c.metadata);
        cj["format"] = Json(c.format);
        cj["status"] = Json(c.status == CredentialStatus.active ? "active" : "disabled");
        cj["version"] = Json(c.version_);
        jarr ~= cj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) creds.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetCredential(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);

      // Support conditional read via If-None-Match
      auto ifNoneMatch = req.headers.get("If-None-Match", "");

      auto c = uc.get_(id);
      if (c.id.length == 0) {
        writeError(res, 404, "Credential not found");
        return;
      }

      // If version matches If-None-Match, return 304
      if (ifNoneMatch.length > 0) {
        try {
          auto matchVer = ifNoneMatch.to!long;
          if (matchVer == c.version_) {
            res.writeBody("", 304);
            return;
          }
        } catch (Exception) {
        }
      }

      auto cj = Json.emptyObject;
      cj["id"] = Json(c.id);
      cj["name"] = Json(c.name);
      cj["value"] = Json(c.value);
      cj["metadata"] = Json(c.metadata);
      cj["format"] = Json(c.format);
      cj["username"] = Json(c.username);
      cj["version"] = Json(c.version_);
      cj["createdAt"] = Json(c.createdAt);
      cj["updatedAt"] = Json(c.updatedAt);
      res.writeJsonBody(cj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteCredential(scope HTTPServerRequest req, scope HTTPServerResponse res) {
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
