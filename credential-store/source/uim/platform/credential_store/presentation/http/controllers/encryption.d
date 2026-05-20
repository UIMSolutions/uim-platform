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

class EncryptionController : PlatformController {
  private EncryptDekUseCase usecase;

  this(EncryptDekUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/encryption/generate", &handleGenerate);
    router.post("/api/v1/encryption/encrypt", &handleEncrypt);
    router.post("/api/v1/encryption/decrypt", &handleDecrypt);
  }

  protected void handleGenerate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      GenerateDekRequest r;
      r.tenantId = tenantId;
      r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", j.getString("namespaceId")));
      r.keyringName = j.getString("keyringName");

      auto result = usecase.generate(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("dek", Json(result.dek))
          .set("encryptedDek", Json(result.encryptedDek))
          .set("keyringId", result.keyringId.value)
          .set("keyringVersion", Json(result.keyringVersion));

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleEncrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      EncryptDekRequest r;
      r.tenantId = tenantId;
      r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", j.getString("namespaceId")));
      r.keyringName = j.getString("keyringName");
      r.dek = j.getString("dek");

      auto result = usecase.encrypt(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("encryptedDek", Json(result.encryptedDek))
          .set("keyringId", result.keyringId.value)
          .set("keyringVersion", Json(result.keyringVersion));

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDecrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      DecryptDekRequest r;
      r.tenantId = tenantId;
      r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", j.getString("namespaceId")));
      r.keyringName = j.getString("keyringName");
      r.encryptedDek = j.getString("encryptedDek");
      r.keyringVersion = jsonLong(j, "keyringVersion");

      auto result = usecase.decrypt(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("dek", Json(result.dek));

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
