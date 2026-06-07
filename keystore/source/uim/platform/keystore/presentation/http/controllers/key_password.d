/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.key_password;

import uim.platform.keystore;

// mixin(ShowModule!());

@safe:

class KeyPasswordController : ManageHttpController {
  private ManageKeyPasswordsUseCase usecase;

  this(ManageKeyPasswordsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // Password Storage API: set, get, delete, list
    router.get("/api/v1/passwords", &handleList);
    router.put("/api/v1/passwords/*", &handleSetPassword);
    router.get("/api/v1/passwords/*", &handleGet);
    router.delete_("/api/v1/passwords/*", &handleDelete);
  }

  protected Json setPasswordHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    SetPasswordRequest r;
    r.tenantId = tenantId;
    r.accountId = data.getString("accountId");
    r.applicationId = data.getString("applicationId");
    r.alias_ = extractIdFromPath(req.requestURI.to!string);
    r.passwordValue = data.getString("passwordValue");

    auto result = usecase.setPassword(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Password set successfully", 200, responseData);
  }

  // PUT /api/v1/passwords/{alias}  (set or overwrite a password)
  protected void handleSetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = setPasswordHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto alias_ = extractIdFromPath(req.requestURI.to!string);
    auto accountId = req.params.get("accountId", "");
    auto applicationId = req.params.get("applicationId", "");

    auto kp = usecase.getPassword(tenantId, accountId, applicationId, alias_);
    if (kp.isNull) {
      return errorResponse("Password not found", 404);
    }

    // Return alias and metadata only — never expose the stored value in clear text
    auto j = Json.emptyObject
      .set("id", kp.id)
      .set("alias", kp.alias_)
      .set("accountId", kp.accountId)
      .set("applicationId", kp.applicationId)
      .set("createdAt", kp.createdAt)
      .set("updatedAt", kp.updatedAt);
    return successResponse("Password retrieved successfully", 200, j);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto alias_ = extractIdFromPath(req.requestURI.to!string);
    auto accountId = req.params.get("accountId", "");
    auto applicationId = req.params.get("applicationId", "");

    auto result = usecase.deletePassword(tenantId, accountId, applicationId, alias_);
    if (result.hasError)
      return errorResponse(result.message, 400);
    else if (result.isSuccess) {
      return successResponse("Password deleted successfully", 204);
    } else {
      return errorResponse("Password not found", 404);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto accountId = req.params.get("accountId", "");
    auto applicationId = req.params.get("applicationId", "");

    auto passwords = usecase.listByApplication(tenantId, accountId, applicationId);

    auto jarr = Json.emptyArray;
    foreach (kp; passwords) {
      jarr ~= Json.emptyObject
        .set("id", kp.id)
        .set("alias", kp.alias_)
        .set("accountId", kp.accountId)
        .set("applicationId", kp.applicationId)
        .set("createdAt", kp.createdAt)
        .set("updatedAt", kp.updatedAt);
    }

    auto resp = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", passwords.length);

    return successResponse("Passwords listed successfully", 200, resp);
  }
}
