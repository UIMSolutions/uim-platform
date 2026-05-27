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
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      AssignEntitlementRequest r;
      r.globalAccountId = data.getString("globalAccountId");
      r.directoryId = data.getString("directoryId");
      r.subaccountId = data.getString("subaccountId");
      r.servicePlanId = data.getString("servicePlanId");
      r.serviceName = data.getString("serviceName");
      r.planName = data.getString("planName");
      r.quotaAssigned = data.getInteger("quotaAssigned");
      r.unlimited = data.getBoolean("unlimited");
      r.autoAssign = data.getBoolean("autoAssign");
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
      auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
      auto id = EntitlementId(extractId(req.requestURI));

      auto data = precheck.data;
      UpdateEntitlementQuotaRequest request;
      request.tenantId = tenantId;
      request.entitlementId = id;
      request.quotaAssigned = data.getInteger("quotaAssigned");
      request.unlimited = data.getBoolean("unlimited");

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
      auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
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

