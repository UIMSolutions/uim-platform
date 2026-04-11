/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.entitlement;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.entitlements;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EntitlementController : PlatformController {
  private ManageEntitlementsUseCase uc;

  this(ManageEntitlementsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/entitlements", &handleAssign);
    router.get("/api/v1/entitlements", &handleList);
    router.get("/api/v1/entitlements/*", &handleGet);
    router.put("/api/v1/entitlements/*", &handleUpdateQuota);
    router.post("/api/v1/entitlements/revoke/*", &handleRevoke);
    router.delete_("/api/v1/entitlements/*", &handleDelete);
  }

  private void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      AssignEntitlementRequest r;
      r.globalAccountId = j.getString("globalAccountId");
      r.directoryId = j.getString("directoryId");
      r.subaccountId = j.getString("subaccountId");
      r.servicePlanId = j.getString("servicePlanId");
      r.serviceName = j.getString("serviceName");
      r.planName = j.getString("planName");
      r.quotaAssigned = j.getInteger("quotaAssigned");
      r.unlimited = j.getBoolean("unlimited");
      r.autoAssign = j.getBoolean("autoAssign");
      r.assignedBy = req.headers.get("X-User-Id", "");

      auto result = uc.assign(r);
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
      auto subId = req.params.get("subaccountId");
      auto dirId = req.params.get("directoryId");

      Entitlement[] items;
      if (subId.length > 0)
        items = uc.listBySubaccount(subId);
      else if (dirId.length > 0)
        items = uc.listByDirectory(dirId);
      else if (gaId.length > 0)
        items = uc.listByGlobalAccount(gaId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serializeEntitlement(e);

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
      auto ent = uc.getById(id);
      if (ent.id.isEmpty) {
        writeError(res, 404, "Entitlement not found");
        return;
      }
      res.writeJsonBody(serializeEntitlement(ent), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateQuota(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateEntitlementQuotaRequest request;
      request.quotaAssigned = j.getInteger("quotaAssigned");
      request.unlimited = j.getBoolean("unlimited");

      auto result = uc.updateQuota(id, request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.revoke(id);
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

private Json serializeEntitlement(Entitlement e) {
  return Json.emptyObject
    .set("id", e.id)
    .set("globalAccountId", e.globalAccountId)
    .set("directoryId", e.directoryId)
    .set("subaccountId", e.subaccountId)
    .set("servicePlanId", e.servicePlanId)
    .set("serviceName", e.serviceName)
    .set("planName", e.planName)
    .set("planDisplayName", e.planDisplayName)
    .set("category", to!string(e.category))
    .set("status", to!string(e.status))
    .set("quotaAssigned", e.quotaAssigned)
    .set("quotaUsed", e.quotaUsed)
    .set("quotaRemaining", e.quotaRemaining)
    .set("unlimited", e.unlimited)
    .set("autoAssign", e.autoAssign)
    .set("assignedAt", e.assignedAt)
    .set("modifiedAt", e.modifiedAt)
    .set("assignedBy", e.assignedBy);
}
