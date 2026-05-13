/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.subaccount;





// import uim.platform.management.application.usecases.manage.subaccounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class SubaccountController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateSubaccountRequest r;
      r.tenantId = tenantId;
      r.globalAccountId = j.getString("globalAccountId");
      r.parentDirectoryId = j.getString("parentDirectoryId");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.subdomain = j.getString("subdomain");
      r.region = j.getString("region");
      r.usage = j.getString("usage");
      r.betaEnabled = j.getBoolean("betaEnabled");
      r.usedForProduction = j.getBoolean("usedForProduction");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.labels = jsonStrMap(j, "labels");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto gaId = req.params.get("globalAccountId");
      auto dirId = req.params.get("directoryId");
      auto region = req.params.get("region");

      Subaccount[] items;
      if (!dirId.isEmpty)
        items = usecase.listByDirectory(dirId);
      else if (!region.isEmpty && !gaId.isEmpty)
        items = usecase.listByRegion(gaId, region);
      else if (!gaId.isEmpty)
        items = usecase.listByGlobalAccount(gaId);

      auto arr = items.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Subaccounts retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto s = usecase.getById(tenantId, id);
      if (s.isNull) {
        writeError(res, 404, "Subaccount not found");
        return;
      }
      res.writeJsonBody(s.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubaccountId(extractId(req.requestURI));
      auto j = req.json;
      UpdateSubaccountRequest r;
      r.tenantId = tenantId;
      r.subaccountId = id;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.usage = j.getString("usage");
      r.betaEnabled = j.getBoolean("betaEnabled");
      r.usedForProduction = j.getBoolean("usedForProduction");
      r.labels = jsonStrMap(j, "labels");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.updateSubaccount(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubaccountId(extractId(req.requestURI));
      auto j = req.json;
      MoveSubaccountRequest r;
      r.tenantId = tenantId;
      r.subaccountId = id;
      r.globalAccountId = j.getString("globalAccountId");
      r.targetDirectoryId = j.getString("targetDirectoryId");

      auto result = usecase.moveSubaccount(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubaccountId(extractId(req.requestURI));
      auto result = usecase.suspendSubaccount(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetReactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubaccountId(extractId(req.requestURI));
      auto result = usecase.reactivateSubaccount(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubaccountId(extractId(req.requestURI));
      auto result = usecase.deleteSubaccount(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
