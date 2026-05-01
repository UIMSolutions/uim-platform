/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.keystore;

import uim.platform.keystore;

@safe:

class KeystoreController : PlatformController {
  private ManageKeystoresUseCase  uc;
  private KeystoreSearchService   searchSvc;

  this(ManageKeystoresUseCase uc, KeystoreSearchService searchSvc) {
    this.uc        = uc;
    this.searchSvc = searchSvc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/keystores",       &handleUpload);
    router.get("/api/v1/keystores",        &handleList);
    router.get("/api/v1/keystores/*",      &handleGet);
    router.put("/api/v1/keystores/*",      &handleUpdate);
    router.delete_("/api/v1/keystores/*",  &handleDelete);
    // Resolve by name with scope (mirrors SAP list-keystores / download-keystore)
    router.get("/api/v1/keystores/resolve", &handleResolve);
  }

  // POST /api/v1/keystores
  private void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UploadKeystoreRequest r;
      r.accountId     = j.getString("accountId");
      r.applicationId = j.getString("applicationId");
      r.subscriptionId = j.getString("subscriptionId");
      r.level         = j.getString("level");
      r.name          = j.getString("name");
      r.description   = j.getString("description");
      r.format        = j.getString("format");
      r.content       = j.getString("content");
      r.createdBy     = j.getString("createdBy");

      auto result = uc.upload(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores?accountId=...&applicationId=...
  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto accountId     = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");

      KeystoreEntity[] keystores;
      if (applicationId.length > 0) {
        keystores = uc.listByApplication(accountId, applicationId);
      } else {
        keystores = uc.listByAccount(accountId);
      }

      auto jarr = Json.emptyArray;
      foreach (ks; keystores) {
        jarr ~= Json.emptyObject
          .set("id",            ks.id)
          .set("name",          ks.name)
          .set("description",   ks.description)
          .set("format",        keystoreFormatToString(ks.format))
          .set("level",         keystoreLevelToString(ks.level))
          .set("accountId",     ks.accountId)
          .set("applicationId", ks.applicationId)
          .set("createdBy",     ks.createdBy)
          .set("createdAt",     ks.createdAt)
          .set("updatedAt",     ks.updatedAt);
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
  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto ks = uc.getById(id);
      if (ks.id.length == 0) {
        writeError(res, 404, "Keystore not found");
        return;
      }
      auto j = Json.emptyObject
        .set("id",            ks.id)
        .set("name",          ks.name)
        .set("description",   ks.description)
        .set("format",        keystoreFormatToString(ks.format))
        .set("level",         keystoreLevelToString(ks.level))
        .set("content",       ks.content)
        .set("accountId",     ks.accountId)
        .set("applicationId", ks.applicationId)
        .set("createdBy",     ks.createdBy)
        .set("updatedBy",    ks.updatedBy)
        .set("createdAt",     ks.createdAt)
        .set("updatedAt",     ks.updatedAt);
        
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // PUT /api/v1/keystores/{id}
  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto j = req.json;
      UpdateKeystoreRequest r;
      r.description = j.getString("description");
      r.content     = j.getString("content");
      r.updatedBy  = j.getString("updatedBy");

      auto result = uc.update(id, r);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      } else {
        writeError(res, result.error == "Keystore not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/keystores/{id}
  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id     = extractIdFromPath(req);
      auto result = uc.removeById(id);
      if (result.success) {
        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores/resolve?name=...&accountId=...&applicationId=...&subscriptionId=...
  private void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto name           = req.params.get("name", "");
      auto accountId      = req.params.get("accountId", "");
      auto applicationId  = req.params.get("applicationId", "");
      auto subscriptionId = req.params.get("subscriptionId", "");

      if (name.length == 0 || accountId.length == 0) {
        writeError(res, 400, "name and accountId are required");
        return;
      }

      auto ks = searchSvc.findByName(accountId, applicationId, subscriptionId, name);
      if (ks.id.length == 0) {
        writeError(res, 404, "Keystore not found");
        return;
      }

      auto j = Json.emptyObject
        .set("id",            ks.id)
        .set("name",          ks.name)
        .set("description",   ks.description)
        .set("format",        keystoreFormatToString(ks.format))
        .set("level",         keystoreLevelToString(ks.level))
        .set("content",       ks.content)
        .set("accountId",     ks.accountId)
        .set("applicationId", ks.applicationId);
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private string keystoreLevelToString(KeystoreLevel level) @safe {
    final switch (level) {
      case KeystoreLevel.account:      return "account";
      case KeystoreLevel.application:  return "application";
      case KeystoreLevel.subscription: return "subscription";
    }
  }
}
