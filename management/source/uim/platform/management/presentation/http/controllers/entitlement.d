/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.entitlement;


// 
// import uim.platform.management.application.usecases.manage.entitlements;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EntitlementController : ManageController {
  private ManageEntitlementsUseCase usecase;

  this(ManageEntitlementsUseCase usecase) {
    this.usecase = usecase;
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

  protected void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto data = precheck.data;
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
      r.assignedBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.assign(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto gaId = req.params.get("globalAccountId");
      auto subId = req.params.get("subaccountId");
      auto dirId = req.params.get("directoryId");

      Entitlement[] items;
      if (!subId.isEmpty)
        items = usecase.listEntitlements(tenantId, subId);
      else if (!dirId.isEmpty)
        items = usecase.listEntitlements(tenantId, dirId);
      else if (!gaId.isEmpty)
        items = usecase.listEntitlements(tenantId, gaId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Entitlements retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto ent = usecase.getEntitlement(tenantId, id);
      if (ent.isNull) {
        writeError(res, 404, "Entitlement not found");
        return;
      }
      res.writeJsonBody(ent.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdateQuota(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = EntitlementId(extractId(req.requestURI));

      auto data = precheck.data;
      UpdateEntitlementQuotaRequest request;
      request.tenantId = tenantId;
      request.entitlementId = id;
      request.quotaAssigned = j.getInteger("quotaAssigned");
      request.unlimited = j.getBoolean("unlimited");

      auto result = usecase.updateEntitlementQuota(request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = EntitlementId(extractId(req.requestURI));

      auto result = usecase.revokeEntitlement(tenantId, id);
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
      auto id = EntitlementId(extractId(req.requestURI));

      auto result = usecase.deleteEntitlement(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

