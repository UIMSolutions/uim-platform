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
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UploadKeystoreRequest r;
    r.tenantId = tenantId;
    r.accountId = data.getString("accountId");
    r.applicationId = data.getString("applicationId");
    r.subscriptionId = data.getString("subscriptionId");
    r.level = data.getString("level");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.format = data.getString("format");
    r.content = data.getString("content");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.uploadKeystore(r);
    if (result.hasError)
      return errorResponse(result.message);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Keystore uploaded successfully", 201, responseData);
  }
  // POST /api/v1/keystores
  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = uploadHandler(req);
      res.writeJsonBody(response, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores?accountId=...&applicationId=...
  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto namespaceId = req.headers.get("X-Namespace-Id", req.params.get("namespaceId", ""));
    auto accountId = req.params.get("accountId", "");
    auto applicationId = req.params.get("applicationId", "");

    Keystore[] keystores = applicationId.isEmpty
      ? usecase.listKeystores(tenantId, accountId) : usecase.listKeystores(tenantId, accountId, applicationId);

    auto list = Json.emptyArray;
    foreach (ks; keystores) {
      list ~= Json.emptyObject
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

    auto responseData = Json.emptyObject
      .set("count", keystores.length)
      .set("resources", list);
    return successResponse("Keystore list retrieved successfully", "Retrieved", 200, responseData);
  }

  // GET /api/v1/keystores/{id}
  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = KeystoreId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid keystore ID", 400);

    auto ks = usecase.getKeystore(tenantId, id);
    if (ks.isNull)
      return errorResponse("Keystore not found", 404);

    auto responseData = Json.emptyObject
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

    return successResponse("Keystore retrieved successfully", "Retrieved", 200, responseData);
  }

  // PUT /api/v1/keystores/{id}
  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = KeystoreId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid keystore ID", 400);

    auto data = precheck.data;
    UpdateKeystoreRequest r;
    r.tenantId = tenantId;
    r.keystoreId = id;
    r.description = data.getString("description");
    r.content = data.getString("content");
    r.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.updateKeystore(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Keystore updated successfully", "Updated", 200, responseData);
  }

  // DELETE /api/v1/keystores/{id}
  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = KeystoreId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid keystore ID", 400);

    auto result = usecase.deleteKeystore(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Keystore deleted successfully", "Deleted", 200, responseData);
  }

  protected Json resolveHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto name = req.params.get("name", "");
    auto accountId = req.params.get("accountId", "");
    auto applicationId = req.params.get("applicationId", "");
    auto subscriptionId = req.params.get("subscriptionId", "");

    if (name.length == 0 || accountId.length == 0)
      return errorResponse("name and accountId are required", 400);

    auto ks = searchSvc.findByName(tenantId, accountId, applicationId, subscriptionId, name);
    if (ks.isNull)
      return errorResponse("Keystore not found", 404);

    auto responseData = Json.emptyObject
      .set("id", ks.id)
      .set("name", ks.name)
      .set("description", ks.description)
      .set("format", ks.format.to!string)
      .set("level", ks.level.to!string)
      .set("content", ks.content)
      .set("accountId", ks.accountId)
      .set("applicationId", ks.applicationId);
    return successResponse("Keystore resolved successfully", "Resolved", 200, responseData);
  }

  // GET /api/v1/keystores/resolve?name=...&accountId=...&applicationId=...&subscriptionId=...
  protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = resolveHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
