/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.subaccount;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;

// import uim.platform.management.application.usecases.manage.subaccounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class SubaccountController : PlatformController {
  private ManageSubaccountsUseCase uc;

  this(ManageSubaccountsUseCase uc) {
    this.uc = uc;
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSubaccountRequest r;
      r.globalAccountId = j.getString("globalAccountId");
      r.parentDirectoryId = j.getString("parentDirectoryId");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.subdomain = j.getString("subdomain");
      r.region = j.getString("region");
      r.usage = j.getString("usage");
      r.betaEnabled = j.getBoolean("betaEnabled");
      r.usedForProduction = j.getBoolean("usedForProduction");
      r.createdBy = req.headers.get("X-User-Id", "");
      r.labels = jsonStrMap(j, "labels");
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
      auto gaId = req.params.get("globalAccountId");
      auto dirId = req.params.get("directoryId");
      auto region = req.params.get("region");

      Subaccount[] items;
      if (dirId.length > 0)
        items = uc.listByDirectory(dirId);
      else if (region.length > 0 && gaId.length > 0)
        items = uc.listByRegion(gaId, region);
      else if (gaId.length > 0)
        items = uc.listByGlobalAccount(gaId);

      auto arr = Json.emptyArray;
      foreach (s; items)
        arr ~= serializeSubaccount(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto s = uc.getById(id);
      if (s.id.isEmpty) {
        writeError(res, 404, "Subaccount not found");
        return;
      }
      res.writeJsonBody(serializeSubaccount(s), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateSubaccountRequest r;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.usage = j.getString("usage");
      r.betaEnabled = j.getBoolean("betaEnabled");
      r.usedForProduction = j.getBoolean("usedForProduction");
      r.labels = jsonStrMap(j, "labels");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = uc.update(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      MoveSubaccountRequest r;
      r.targetDirectoryId = j.getString("targetDirectoryId");

      auto result = uc.moveSubaccount(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
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

private Json serializeSubaccount(Subaccount subaccount) {
  return Json.emptyObject
    .set("id", subaccount.id)
    .set("globalAccountId", subaccount.globalAccountId)
    .set("parentDirectoryId", subaccount.parentDirectoryId)
    .set("displayName", subaccount.displayName)
    .set("description", subaccount.description)
    .set("subdomain", subaccount.subdomain)
    .set("region", subaccount.region)
    .set("status", to!string(subaccount.status))
    .set("usage", to!string(subaccount.usage))
    .set("betaEnabled", subaccount.betaEnabled)
    .set("usedForProduction", subaccount.usedForProduction)
    .set("tenantId", subaccount.tenantId)
    .set("createdAt", subaccount.createdAt)
    .set("modifiedAt", subaccount.modifiedAt)
    .set("createdBy", subaccount.createdBy)
    .set("labels", subaccount.labels)
    .set("customProperties", subaccount.customProperties);
}

