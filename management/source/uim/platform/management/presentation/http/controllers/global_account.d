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
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class GlobalAccountController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateGlobalAccountRequest r;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.contractNumber = j.getString("contractNumber");
      r.licenseType = j.getString("licenseType");
      r.region = j.getString("region");
      r.costCenter = j.getString("costCenter");
      r.companyName = j.getString("companyName");
      r.contactEmail = j.getString("contactEmail");
      r.maxSubaccounts = j.getInteger("maxSubaccounts", 100);
      r.maxDirectories = j.getInteger("maxDirectories", 20);
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto statusFilter = req.params.get("status");
      GlobalAccount[] items;
      if (statusFilter.length > 0)
        items = usecase.listByStatus(statusFilter);
      else
        items = usecase.listAll();

      auto arr = items.map!(ga => ga.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Global accounts retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      if (!usecase.existsById(id)) {
        writeError(res, 404, "Global account not found");
        return;
      }
      
      auto ga = usecase.getById(tenantId, id);
      res.writeJsonBody(ga.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateGlobalAccountRequest request;
      request.displayName = j.getString("displayName");
      request.description = j.getString("description");
      request.costCenter = j.getString("costCenter");
      request.contactEmail = j.getString("contactEmail");
      request.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.update(id, request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto result = usecase.suspend(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleReactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto result = usecase.reactivate(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = GlobalAccountId(extractId(req.requestURI));
      auto result = usecase.deleteGlobalAccount(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeGlobalAccount(GlobalAccount ga) {
  return Json.emptyObject
    .set("id", ga.id)
    .set("displayName", ga.displayName)
    .set("description", ga.description)
    .set("contractNumber", ga.contractNumber)
    .set("licenseType", to!string(ga.licenseType))
    .set("status", to!string(ga.status))
    .set("region", ga.region)
    .set("costCenter", ga.costCenter)
    .set("companyName", ga.companyName)
    .set("contactEmail", ga.contactEmail)
    .set("maxSubaccounts", ga.maxSubaccounts)
    .set("currentSubaccounts", ga.currentSubaccounts)
    .set("maxDirectories", ga.maxDirectories)
    .set("currentDirectories", ga.currentDirectories)
    .set("createdAt", ga.createdAt)
    .set("updatedAt", ga.updatedAt)
    .set("createdBy", ga.createdBy)
    .set("customProperties", ga.customProperties.toJson);
}
