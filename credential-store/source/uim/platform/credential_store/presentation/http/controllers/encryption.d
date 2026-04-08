/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.encryption;

// import uim.platform.credential_store.application.usecases.encrypt_dek;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class EncryptionController : SAPController {
  private EncryptDekUseCase uc;

  this(EncryptDekUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/encryption/generate", &handleGenerate);
    router.post("/api/v1/encryption/encrypt", &handleEncrypt);
    router.post("/api/v1/encryption/decrypt", &handleDecrypt);
  }

  private void handleGenerate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      GenerateDekRequest r;
      r.tenantId = req.getTenantId;
      r.namespaceId = req.headers.get("X-Namespace-Id", j.getString("namespaceId"));
      r.keyringName = j.getString("keyringName");

      auto result = uc.generate(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["dek"] = Json(result.dek);
        resp["encryptedDek"] = Json(result.encryptedDek);
        resp["keyringId"] = Json(result.keyringId);
        resp["keyringVersion"] = Json(result.keyringVersion);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleEncrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      EncryptDekRequest r;
      r.tenantId = req.getTenantId;
      r.namespaceId = req.headers.get("X-Namespace-Id", j.getString("namespaceId"));
      r.keyringName = j.getString("keyringName");
      r.dek = j.getString("dek");

      auto result = uc.encrypt(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["encryptedDek"] = Json(result.encryptedDek);
        resp["keyringId"] = Json(result.keyringId);
        resp["keyringVersion"] = Json(result.keyringVersion);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDecrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      DecryptDekRequest r;
      r.tenantId = req.getTenantId;
      r.namespaceId = req.headers.get("X-Namespace-Id", j.getString("namespaceId"));
      r.keyringName = j.getString("keyringName");
      r.encryptedDek = j.getString("encryptedDek");
      r.keyringVersion = jsonLong(j, "keyringVersion");

      auto result = uc.decrypt(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["dek"] = Json(result.dek);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
