/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.keyring;
// import uim.platform.credential_store.application.usecases.manage.usecase;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class KeyringController : ManageController {
  private ManageKeyringsUseCase usecase;

  this(ManageKeyringsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usecase", &handleCreate);
    router.get("/api/v1/usecase", &handleList);
    router.get("/api/v1/usecase/*", &handleGet);
    router.post("/api/v1/usecase/rotate", &handleRotate);
    router.post("/api/v1/usecase/disable", &handleDisable);
    router.delete_("/api/v1/usecase/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateKeyringRequest r;
    r.tenantId = tenantId;
    r.namespaceId = req.headers.get("X-Namespace-Id", data.getString("namespaceId"));
    r.name = data.getString("name");
    r.metadata = data.getString("metadata");
    r.format = data.getString("format");
    r.rotationPeriodDays = data.getInteger("rotationPeriodDays", 90);
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createKeyring(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Keyring created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto namespaceId = NamespaceId(req.headers.get("X-Namespace-Id", req.params.get("namespaceId", "")));

    auto rings = usecase.listCredentials(tenantId, namespaceId);
    auto list = Json.emptyArray;
    foreach (k; rings) {
      list ~= Json.emptyObject
        .set("id", k.id)
        .set("name", k.name)
        .set("metadata", k.metadata)
        .set("version", k.version_);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Keyring list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CredentialId(precheck.id);
    auto k = usecase.getCredential(tenantId, id);

    if (k.isNull) {
      return errorResponse("Keyring not found", 404);
    }

    auto versions = usecase.getKeyringVersions(tenantId, k.id);

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

    return successResponse("Keyring retrieved successfully", "Retrieved", 200, kj);
  }

  protected Json rotateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RotateKeyringRequest r;
    r.keyringId = data.getString("keyringId");
    r.tenantId = tenantId;

    auto result = usecase.rotateKeyring(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("versionId", result.id);
    return successResponse("Keyring rotated successfully", "Rotated", 200, responseData);
  }

  protected void handleRotate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = rotateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json disableHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto keyringId = CredentialId(data.getString("keyringId"));

    auto result = usecase.disableCredential(tenantId, keyringId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Keyring disabled successfully", "Disabled", 200, resp);
  }

  protected void handleDisable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = disableHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CredentialId(precheck.id);

    auto result = usecase.deleteCredential(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Keyring deleted successfully", "Deleted", 200, responseData);
  }
}
