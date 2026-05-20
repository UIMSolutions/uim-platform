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

  protected Json generateHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto data = req.json;

    GenerateDekRequest r;
    r.tenantId = tenantId;
    r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", data.getString("namespaceId")));
    r.keyringName = data.getString("keyringName");

    auto encryption = usecase.generate(r);
    if (!encryption.success)
      return errorResponse("Failed to generate DEK", 400);

    auto resp = Json.emptyObject
      .set("dek", encryption.dek)
      .set("encryptedDek", encryption.encryptedDek)
      .set("keyringId", encryption.keyringId.value)
      .set("keyringVersion", encryption.keyringVersion);

    return successResponse("DEK generated successfully", 200, resp);
  }

  protected void handleGenerate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resp = generateHandler(req);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json encryptHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto data = req.json;

    EncryptDekRequest r;
    r.tenantId = tenantId;
    r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", data.getString("namespaceId")));
    r.keyringName = data.getString("keyringName");
    r.dek = data.getString("dek");

    auto result = usecase.encrypt(r);
    if (!result.success)
      return errorResponse("Failed to encrypt DEK", 400);

    auto resp = Json.emptyObject
      .set("encryptedDek", Json(result.encryptedDek))
      .set("keyringId", result.keyringId.value)
      .set("keyringVersion", Json(result.keyringVersion));

    return successResponse("DEK encrypted successfully", 200, resp);
  }

  protected void handleEncrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resp = encryptHandler(req);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json decryptHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto data = req.json;

    DecryptDekRequest r;
    r.tenantId = tenantId;
    r.namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", data.getString("namespaceId")));
    r.keyringName = data.getString("keyringName");
    r.encryptedDek = data.getString("encryptedDek");
    r.keyringVersion = jsonLong(data, "keyringVersion");

    auto result = usecase.decrypt(r);
    if (!result.success)
      return errorResponse("Failed to decrypt DEK", 400);

    auto resp = Json.emptyObject
      .set("dek", Json(result.dek));

    return successResponse("DEK decrypted successfully", 200, resp);
  }

  protected void handleDecrypt(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resp = decryptHandler(req);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
