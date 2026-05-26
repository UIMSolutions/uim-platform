/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.keystore;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeystoreController : ManageController {
  private ManageKeystoresUseCase usecase;
  private KeystoreSearchService searchSvc;

  this(ManageKeystoresUseCase usecase, KeystoreSearchService searchSvc) {
    this.usecase = usecase;
    this.searchSvc = searchSvc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/keystores", &handleUpload);
    router.get("/api/v1/keystores", &handleList);
    router.get("/api/v1/keystores/*", &handleGet);
    router.put("/api/v1/keystores/*", &handleUpdate);
    router.delete_("/api/v1/keystores/*", &handleDelete);
    // Resolve by name with scope (mirrors SAP list-keystores / download-keystore)
    router.get("/api/v1/keystores/resolve", &handleResolve);
  }

  protected Json uploadHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto j = req.json;
    UploadKeystoreRequest r;
    r.tenantId = tenantId;
    r.accountId = j.getString("accountId");
    r.applicationId = j.getString("applicationId");
    r.subscriptionId = j.getString("subscriptionId");
    r.level = j.getString("level");
    r.name = j.getString("name");
    r.description = j.getString("description");
    r.format = j.getString("format");
    r.content = j.getString("content");
    r.createdBy = UserId(j.getString("createdBy"));

    auto result = usecase.uploadKeystore(r);
    if (result.hasError) 
      return errorResponse(result.message);

    return successResponse("Keystore uploaded successfully", 201, Json.emptyObject.set("id", result.id));
  }
  // POST /api/v1/keystores
  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      UploadKeystoreRequest r;
      r.tenantId = tenantId;
      r.accountId = j.getString("accountId");
      r.applicationId = j.getString("applicationId");
      r.subscriptionId = j.getString("subscriptionId");
      r.level = j.getString("level");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.format = j.getString("format");
      r.content = j.getString("content");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.uploadKeystore(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores?accountId=...&applicationId=...
  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto namespaceId = req.headers.get("X-Namespace-Id", req.params.get("namespaceId", ""));
      auto accountId = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");

      Keystore[] keystores = applicationId.isEmpty
        ? usecase.listKeystores(tenantId, accountId) 
        : usecase.listKeystores(tenantId, accountId, applicationId);

      auto jarr = Json.emptyArray;
      foreach (ks; keystores) {
        jarr ~= Json.emptyObject
          .set("id", ks.id)
          .set("name", ks.name)
          .set("description", ks.description)
          .set("format", ks.format.to!string)
          .set("level", ks.level.to!string)
          .set("accountId", ks.accountId)
          .set("applicationId", ks.applicationId)
          .set("createdBy", ks.createdBy)
          .set("createdAt", ks.createdAt)
          .set("updatedAt", ks.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", keystores.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores/{id}
  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = Keystoreprecheck.id);

      auto ks = usecase.getKeystore(tenantId, id);
      if (ks.isNull) {
        writeError(res, 404, "Keystore not found");
        return;
      }
      auto j = Json.emptyObject
        .set("id", ks.id)
        .set("name", ks.name)
        .set("description", ks.description)
        .set("format", ks.format.to!string)
        .set("level", ks.level.to!string)
        .set("content", ks.content)
        .set("accountId", ks.accountId)
        .set("applicationId", ks.applicationId)
        .set("createdBy", ks.createdBy)
        .set("updatedBy", ks.updatedBy)
        .set("createdAt", ks.createdAt)
        .set("updatedAt", ks.updatedAt);

      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // PUT /api/v1/keystores/{id}
  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = Keystoreprecheck.id);

      auto j = req.json;
      UpdateKeystoreRequest r;
      r.tenantId = tenantId;
      r.keystoreId = id;
      r.description = j.getString("description");
      r.content = j.getString("content");
      r.updatedBy = UserId(j.getString("updatedBy"));

      auto result = usecase.updateKeystore(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      } else {
        writeError(res, result.message == "Keystore not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/keystores/{id}
  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = Keystoreprecheck.id);
      auto result = usecase.deleteKeystore(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores/resolve?name=...&accountId=...&applicationId=...&subscriptionId=...
  protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto name = req.params.get("name", "");
      auto accountId = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");
      auto subscriptionId = req.params.get("subscriptionId", "");

      if (name.length == 0 || accountId.length == 0) {
        writeError(res, 400, "name and accountId are required");
        return;
      }

      auto ks = searchSvc.findByName(tenantId, accountId, applicationId, subscriptionId, name);
      if (ks.isNull) {
        writeError(res, 404, "Keystore not found");
        return;
      }

      auto j = Json.emptyObject
        .set("id", ks.id)
        .set("name", ks.name)
        .set("description", ks.description)
        .set("format", ks.format.to!string)
        .set("level", ks.level.to!string)
        .set("content", ks.content)
        .set("accountId", ks.accountId)
        .set("applicationId", ks.applicationId);
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
