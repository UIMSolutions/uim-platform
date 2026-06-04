/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.subaccount;

// import uim.platform.management.application.usecases.manage.subaccounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subaccount;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class SubaccountController : ManageHttpController {
  private ManageSubaccountsUseCase usecase;

  this(ManageSubaccountsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/subaccounts", &handleCreate);
    router.get("/api/v1/subaccounts", &handleList);
    router.get("/api/v1/subaccounts/*", &handleGet);
    router.put("/api/v1/subaccounts/*", &handleUpdate);
    router.post("/api/v1/subaccounts/move/*", &handleMove);
    router.post("/api/v1/subaccounts/suspend/*", &handleSuspend);
    router.post("/api/v1/subaccounts/reactivate/*", &handleReactivate);
    router.delete_("/api/v1/subaccounts/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateSubaccountRequest r;
    r.tenantId = tenantId;
    r.globalAccountId = data.getString("globalAccountId");
    r.parentDirectoryId = data.getString("parentDirectoryId");
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.subdomain = data.getString("subdomain");
    r.region = data.getString("region");
    r.usage = data.getString("usage");
    r.betaEnabled = data.getBoolean("betaEnabled");
    r.usedForProduction = data.getBoolean("usedForProduction");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.labels = data.jsonStrMap("labels");
    r.customProperties = data.jsonStrMap("customProperties");

    auto result = usecase.createSubaccount(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto gaId = GlobalAccountId(req.params.get("globalAccountId", ""));
    auto dirId = DirectoryId(req.params.get("directoryId", ""));
    auto region = req.params.get("region", "");

    Subaccount[] items;
    if (!dirId.isEmpty)
      items = usecase.listSubaccounts(tenantId, dirId);
    else if (!region.isEmpty && !gaId.isEmpty)
      items = usecase.listSubaccounts(tenantId, gaId, region);
    else if (!gaId.isEmpty)
      items = usecase.listSubaccounts(tenantId, gaId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Subaccount list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto s = usecase.getSubaccount(tenantId, id);
    if (s.isNull)
      return errorResponse("Subaccount not found", 404);

    auto responseData = s.toJson();
    return successResponse("Subaccount retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto data = precheck.data;
    UpdateSubaccountRequest r;
    r.tenantId = tenantId;
    r.subaccountId = id;
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.usage = data.getString("usage");
    r.betaEnabled = data.getBoolean("betaEnabled");
    r.usedForProduction = data.getBoolean("usedForProduction");
    r.labels = data.jsonStrMap("labels");
    r.customProperties = data.jsonStrMap("customProperties");

    auto result = usecase.updateSubaccount(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount updated successfully", "Updated", 200, responseData);
  }

  protected Json moveHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto data = precheck.data;
    MoveSubaccountRequest r;
    r.tenantId = tenantId;
    r.subaccountId = id;
    r.globalAccountId = GlobalAccountId(data.getString("globalAccountId"));
    r.targetDirectoryId = DirectoryId(data.getString("targetDirectoryId"));

    auto result = usecase.moveSubaccount(tenantId, id, r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount moved successfully", "Moved", 200, responseData);
  }

  protected void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = moveHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected Json suspendHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto result = usecase.suspendSubaccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount suspended successfully", "Suspended", 200, responseData);
  }

  protected void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = suspendHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected Json reactivateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto result = usecase.reactivateSubaccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount reactivated successfully", "Reactivated", 200, responseData);
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
    auto id = SubaccountId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subaccount ID", 400);

    auto result = usecase.deleteSubaccount(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subaccount deleted successfully", "Deleted", 200, responseData);
  }
}
