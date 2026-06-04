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

import uim.platform.management;

mixin(ShowModule!());
@safe:
class EntitlementController : ManageHttpController {
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

  protected Json assignHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

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

    auto result = usecase.assignEntitlement(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Entitlement assigned successfully", "Created", 201, resp);
  }

  protected void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = assignHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto gaId = GlobalAccountId(req.params.get("globalAccountId"));
    auto subId = SubaccountId(req.params.get("subaccountId"));
    auto dirId = DirectoryId(req.params.get("directoryId"));

    Entitlement[] items;
    if (!subId.isNull)
      items = usecase.listEntitlements(tenantId, subId);
    else if (!dirId.isNull)
      items = usecase.listEntitlements(tenantId, dirId);
    else if (!gaId.isNull)
      items = usecase.listEntitlements(tenantId, gaId);

    auto list = items.map!(e => e.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Entitlements retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = EntitlementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid entitlement ID", 400);

    auto entitlement = usecase.getEntitlement(tenantId, id);
    if (entitlement.isNull)
      return errorResponse("Entitlement not found", 404);

    auto responseData = entitlement.toJson();
    return successResponse("Entitlement retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json updateQuotaHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EntitlementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid entitlement ID", 400);

    auto data = precheck.data;
    UpdateEntitlementQuotaRequest r;
    r.tenantId = tenantId;
    r.entitlementId = id;
    r.quotaAssigned = data.getInteger("quotaAssigned");
    r.unlimited = data.getBoolean("unlimited");

    auto result = usecase.updateEntitlementQuota(r);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Entitlement quota updated successfully", "Updated", 200, responseData);
  }

  protected void handleUpdateQuota(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateQuotaHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected Json revokeHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EntitlementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid entitlement ID", 400);

    auto result = usecase.revokeEntitlement(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Entitlement revoked successfully", "Updated", 200, Json.emptyObject);
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = revokeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EntitlementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid entitlement ID", 400);

    auto result = usecase.deleteEntitlement(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Entitlement deleted successfully", "Deleted", 200, responseData);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class EntitlementControllerTest : ControllerTestBase {
    void runTests() {
      // 1. Setup
      auto repo = new MemoryEntitlementRepository();
      auto usecase = new ManageEntitlementsUseCase(repo, new EntitlementEvaluator);
      auto controller = new EntitlementController(usecase);
      auto tenantId = TenantId("test-tenant");


      // 2. Test List Handler (Initially empty)
      auto reqList = createMockRequest("GET", "/api/v1/entitlements", tenantId);
      reqList.params["globalAccountId"] = "test-account";
      auto resList = controller.listHandler(reqList);
      writeln("Initial List Response: ", resList);
      // assertSuccess(resList, 200);
      // assert(resList["data"]["count"].get!int == 0);

      // 3. Test Assign Handler (Create)
      Json assignData = Json.emptyObject
        .set("globalAccountId", "test-account")
        .set("subaccountId", "test-subaccount")
        .set("servicePlanId", "plan-premium-001")
        .set("serviceName", "redis-service")
        .set("planName", "premium")
        .set("quotaAssigned", 5)
        .set("unlimited", false)
        .set("autoAssign", true);

      // auto reqAssign = createMockRequest("POST", "/api/v1/entitlements", "test-tenant", assignData);
      // auto resAssign = controller.assignHandler(reqAssign);
      // writeln("Assign Response: ", resAssign);
      // string createdId = resAssign["data"]["id"].get!string;
      // // assertSuccess(resAssign, 201);

      // // 4. Test Get Handler
      // auto reqGet = createMockRequest("GET", "/api/v1/entitlements/" ~ createdId);
      // auto resGet = controller.getHandler(reqGet);
      // writeln("Get Response: ", resGet);
      // // assertSuccess(resGet, 200);

      // // 5. Test Update Quota Handler
      // Json updateData = Json.emptyObject
      //   .set("quotaAssigned", 10)
      //   .set("unlimited", true);
      // auto reqUpdate = createMockRequest("PUT", "/api/v1/entitlements/" ~ createdId, "test-tenant", updateData);
      // auto resUpdate = controller.updateQuotaHandler(reqUpdate);
      // writeln("Update Quota Response: ", resUpdate);
      // // assertSuccess(resUpdate, 200);

      // // 6. Test Revoke Handler
      // auto reqRevoke = createMockRequest("POST", "/api/v1/entitlements/revoke/" ~ createdId);
      // auto resRevoke = controller.revokeHandler(reqRevoke);
      // writeln("Revoke Response: ", resRevoke);
      // // assertSuccess(resRevoke, 200);

      // // 7. Test List Handler (Post-Assignment)
      // auto resList2 = controller.listHandler(reqList);
      // writeln("List Response (Post-Assign): ", resList2);
      // // assert(resList2["data"]["count"].get!int == 1);

      // // 8. Test Delete Handler
      // auto reqDelete = createMockRequest("DELETE", "/api/v1/entitlements/" ~ createdId);
      // auto resDelete = controller.deleteHandler(reqDelete);
      // writeln("Delete Response: ", resDelete);
      // // assertSuccess(resDelete, 200);

      // // 9. Test Get Handler (Should be 404 after deletion)
      // auto resGet404 = controller.getHandler(reqGet);
      // writeln("Get 404 Response: ", resGet404);
      // // assert(resGet404["code"].get!int == 404);
    }
  }

  auto runner = new EntitlementControllerTest();
  runner.runTests();
}
