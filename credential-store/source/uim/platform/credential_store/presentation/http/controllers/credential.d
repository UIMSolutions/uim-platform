/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.credential;
// import uim.platform.credential_store.application.usecases.manage.usecase;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class CredentialController : ManageController {
  private ManageCredentialsUseCase usecase;

  this(ManageCredentialsUseCase usecase) {
    this.usecase = usecase;
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

  protected void handleCreatePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "password");
  }

  protected void handleListPasswords(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "password");
  }

  protected void handleGetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res, "");
  }

  protected void handleDeletePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res, "password");
  }

  // --- Key endpoints ---

  protected void handleCreateKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "key");
  }

  protected void handleListKeys(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "key");
  }

  protected void handleGetKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res, "key");
  }

  protected void handleDeleteKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res, "key");
  }

  // --- Shared handlers ---

  protected void handleCreateCredential(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateCredentialRequest r;
      r.tenantId = tenantId;
      r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", data.getString("namespaceId")));
      r.name = data.getString("name");
      r.type = type;
      r.value = data.getString("value");
      r.metadata = data.getString("metadata");
      r.format = data.getString("format");
      r.username = data.getString("username");
      r.createdBy = UserId(data.getString("createdBy"));
      r.ifNoneMatch = req.headers.get("If-None-Match", "");

      auto result = usecase.createCredential(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Credential created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleListCredentials(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = precheck.tenantId;
      auto namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", req.params.get("namespaceId", "")));

      Credential[] creds;
      if (!namespaceId.isEmpty) {
        creds = usecase.listCredentials(tenantId, namespaceId, type);
      }

      auto jarr = Json.emptyArray;
      foreach (c; creds) {
        jarr ~= Json.emptyObject
        .set("id", c.id)
        .set("name", c.name)
        .set("metadata", c.metadata)
        .set("format", c.format)
        .set("status", c.status == CredentialStatus.active ? "active" : "disabled")
        .set("version", c.version_);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", creds.length)
        .set("message", "Credentials retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetCredential(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Credentialprecheck.id);

      // Support conditional read via If-None-Match
      auto ifNoneMatch = req.headers.get("If-None-Match", "");

      auto c = usecase.getCredential(tenantId, id);
      if (c.isNull) {
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

      auto response = Json.emptyObject
        .set("id", c.id)
        .set("name", c.name)
        .set("value", c.value)
        .set("metadata", c.metadata)
        .set("format", c.format)
        .set("username", c.username)
        .set("version", c.version_)
        .set("createdAt", c.createdAt)
        .set("updatedAt", c.updatedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDeleteCredential(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Credentialprecheck.id);

      usecase.deleteCredential(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
