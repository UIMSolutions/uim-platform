/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.global_account;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.global_accounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.global_account;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class GlobalAccountController : PlatformController {
  private ManageGlobalAccountsUseCase uc;

  this(ManageGlobalAccountsUseCase uc) {
    this.uc = uc;
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
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
      r.createdBy = req.headers.get("X-User-Id", "");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto statusFilter = req.params.get("status");
      GlobalAccount[] items;
      if (statusFilter.length > 0)
        items = uc.listByStatus(statusFilter);
      else
        items = uc.listAll();

      auto arr = Json.emptyArray;
      foreach (ga; items)
        arr ~= serializeGlobalAccount(ga);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto ga = uc.getById(id);
      if (ga.id.isEmpty) {
        writeError(res, 404, "Global account not found");
        return;
      }
      res.writeJsonBody(serializeGlobalAccount(ga), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateGlobalAccountRequest r;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.costCenter = j.getString("costCenter");
      r.contactEmail = j.getString("contactEmail");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = uc.update(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.suspend(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleReactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.reactivate(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
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
    .set("maxSubaccounts", cast(long)ga.maxSubaccounts)
    .set("currentSubaccounts", cast(long)ga.currentSubaccounts)
    .set("maxDirectories", cast(long)ga.maxDirectories)
    .set("currentDirectories", cast(long)ga.currentDirectories)
    .set("createdAt", ga.createdAt)
    .set("modifiedAt", ga.modifiedAt)
    .set("createdBy", ga.createdBy)
    .set("customProperties", customProperties);
}

private string to!string(E)(E val) {
  // import std.conv : to;

  return val.to!string;
}
