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

class CredentialController : PlatformController {
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

  protected void handleCreate(Password(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "password");
  }

  protected void handleGetListPasswords(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "password");
  }

  protected void handleGetGetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res);
  }

  protected void handleGetDeletePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res);
  }

  // --- Key endpoints ---

  protected void handleCreate(Key(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleCreateCredential(req, res, "key");
  }

  protected void handleGetListKeys(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleListCredentials(req, res, "key");
  }

  protected void handleGetGetKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleGetCredential(req, res);
  }

  protected void handleGetDeleteKey(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    handleDeleteCredential(req, res);
  }

  // --- Shared handlers ---

  protected void handleCreate(Credential(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateCredentialRequest r;
      r.tenantId = tenantId;
      r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", j.getString("namespaceId")));
      r.name = j.getString("name");
      r.type = type;
      r.value = j.getString("value");
      r.metadata = j.getString("metadata");
      r.format = j.getString("format");
      r.username = j.getString("username");
      r.createdBy = UserId(j.getString("createdBy"));
      r.ifNoneMatch = req.headers.get("If-None-Match", "");

      auto result = usecase.createCredential(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Credential created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetListCredentials(scope HTTPServerRequest req, scope HTTPServerResponse res, string type) {
    try {
      auto tenantId = req.getTenantId;
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

  protected void handleGetGetCredential(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CredentialId(extractIdFromPath(req.requestURI.to!string));

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

  protected void handleGetDeleteCredential(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CredentialId(extractIdFromPath(req.requestURI.to!string));

      usecase.deleteCredential(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
