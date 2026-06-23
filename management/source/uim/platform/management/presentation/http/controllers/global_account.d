/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.global_account;

// 
// import uim.platform.management.application.usecases.manage.global_accounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.global_account;

import uim.platform.management;

// mixin(ShowModule!());
@safe:
class GlobalAccountController : ManageHttpController {
  private ManageGlobalAccountsUseCase usecase;

  this(ManageGlobalAccountsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/accounts", &handleCreate);
    router.get("/api/v1/accounts", &handleList);
    router.get("/api/v1/accounts/*", &handleGet);
    router.put("/api/v1/accounts/*", &handleUpdate);
    router.post("/api/v1/accounts/suspend/*", &handleSuspend);
    router.post("/api/v1/accounts/reactivate/*", &handleReactivate);
    router.delete_("/api/v1/accounts/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateGlobalAccountRequest r;
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.contractNumber = data.getString("contractNumber");
    r.licenseType = data.getString("licenseType");
    r.region = data.getString("region");
    r.costCenter = data.getString("costCenter");
    r.companyName = data.getString("companyName");
    r.contactEmail = data.getString("contactEmail");
    r.maxSubaccounts = data.getInteger("maxSubaccounts", 100);
    r.maxDirectories = data.getInteger("maxDirectories", 20);
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.customProperties = data.jsonStrMap("customProperties");

    auto result = usecase.createAccount(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Global account created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto statusFilter = req.params.get("status");
    GlobalAccount[] items = statusFilter.length > 0
      ? usecase.listAccounts(tenantId, statusFilter) : usecase.listAccounts(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Global accounts retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = GlobalAccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid global account ID", 400);

    auto account = usecase.getAccount(tenantId, id);
    if (account.isNull)
      return errorResponse("Global account not found", 404);

    auto responseData = account.toJson();
    return successResponse("Global account retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = GlobalAccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid global account ID", 400);

    auto data = precheck.data;
    UpdateGlobalAccountRequest request;
    request.displayName = data.getString("displayName");
    request.description = data.getString("description");
    request.costCenter = data.getString("costCenter");
    request.contactEmail = data.getString("contactEmail");
    request.customProperties = data.jsonStrMap("customProperties");

    auto result = usecase.updateAccount(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Global account updated successfully", "Updated", 200, responseData);
  }

  protected Json suspendHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GlobalAccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid global account ID", 400);

    auto result = usecase.suspendAccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Global account suspended successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleSuspend", "suspendHandler"));

  protected Json reactivateHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GlobalAccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid global account ID", 400);

    auto result = usecase.reactivateAccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Global account reactivated successfully", "Updated", 200, responseData);
  }

  protected void handleReactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = reactivateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = GlobalAccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid global account ID", 400);

    auto result = usecase.deleteAccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Global account deleted successfully", "Deleted", 200, responseData);
  }
}
