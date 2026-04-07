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
class GlobalAccountController : SAPController {
  private ManageGlobalAccountsUseCase uc;

  this(ManageGlobalAccountsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
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
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
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
      foreach (ref ga; items)
        arr ~= serializeGlobalAccount(ga);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto ga = uc.getById(id);
      if (ga.id.length == 0) {
        writeError(res, 404, "Global account not found");
        return;
      }
      res.writeJsonBody(serializeGlobalAccount(ga), 200);
    }
    catch (Exception e)
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
    }
    catch (Exception e)
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
    }
    catch (Exception e)
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
    }
    catch (Exception e)
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
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeGlobalAccount(ref GlobalAccount ga) {
  auto j = Json.emptyObject;
  j["id"] = Json(ga.id);
  j["displayName"] = Json(ga.displayName);
  j["description"] = Json(ga.description);
  j["contractNumber"] = Json(ga.contractNumber);
  j["licenseType"] = Json(enumStr(ga.licenseType));
  j["status"] = Json(enumStr(ga.status));
  j["region"] = Json(ga.region);
  j["costCenter"] = Json(ga.costCenter);
  j["companyName"] = Json(ga.companyName);
  j["contactEmail"] = Json(ga.contactEmail);
  j["maxSubaccounts"] = Json(cast(long) ga.maxSubaccounts);
  j["currentSubaccounts"] = Json(cast(long) ga.currentSubaccounts);
  j["maxDirectories"] = Json(cast(long) ga.maxDirectories);
  j["currentDirectories"] = Json(cast(long) ga.currentDirectories);
  j["createdAt"] = Json(ga.createdAt);
  j["modifiedAt"] = Json(ga.modifiedAt);
  j["createdBy"] = Json(ga.createdBy);
  j["customProperties"] = serializeStrMap(ga.customProperties);
  return j;
}

private string enumStr(E)(E val) {
  // import std.conv : to;

  return val.to!string;
}
