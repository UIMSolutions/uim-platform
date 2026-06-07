/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.subscription;

// 
// import uim.platform.management.application.usecases.manage.subscriptions;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subscription;


import uim.platform.management;

// mixin(ShowModule!());
@safe:
class SubscriptionController : ManageHttpController {
  private ManageSubscriptionsUseCase usecase;

  this(ManageSubscriptionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/subscriptions", &handleSubscribe);
    router.get("/api/v1/subscriptions", &handleList);
    router.get("/api/v1/subscriptions/*", &handleGet);
    router.put("/api/v1/subscriptions/*", &handleUpdate);
    router.post("/api/v1/subscriptions/unsubscribe/*", &handleUnsubscribe);
  }

  protected Json subscribeHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    CreateSubscriptionRequest r;
    r.tenantId = tenantId;
    r.subaccountId = SubaccountId(data.getString("subaccountId"));
    r.globalAccountId = GlobalAccountId(data.getString("globalAccountId"));
    r.appName = data.getString("appName");
    r.planName = data.getString("planName");
    r.subscribedBy = UserId(req.headers.get("X-User-Id", ""));
    r.parameters = data.jsonStrMap("parameters");
    r.labels = data.jsonStrMap("labels");

    auto result = usecase.createSubscription(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subscription created successfully", "Created", 201, responseData);
  }

  protected void handleSubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = subscribeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto statusFilter = req.params.get("status");
    auto resourceType = req.params.get("resourceType");
    auto resourceId = req.params.get("resourceId");
    auto subId = SubaccountId(req.params.get("subaccountId"));

    Subscription[] items;
    if (!subId.isEmpty)
      items = usecase.listSubscriptions(tenantId, subId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Subscription list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = SubscriptionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subscription ID", 400);

    auto subscription = usecase.getSubscription(tenantId, id);
    if (subscription.isNull)
      return errorResponse("Subscription not found", 404);

    auto responseData = subscription.toJson();
    return successResponse("Subscription retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = SubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto data = precheck.data;
        UpdateSubscriptionRequest r;
        r.tenantId = tenantId;
        r.subscriptionId = id;
        r.planName = data.getString("planName");
        // r.status = data.getString("status");
        // r.updatedBy = UserId(req.headers.get("X-User-Id", ""));
        r.parameters = data.jsonStrMap("parameters");

      auto result = usecase.updateSubscriptionPlan(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Subscription updated successfully", "Updated", 200, responseData);
  }

  protected Json unsubscribeHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SubscriptionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid subscription ID", 400);

    auto result = usecase.unsubscribeSubscription(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Subscription unsubscribed successfully", "Unsubscribed", 200, responseData);
  }
  protected void handleUnsubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = unsubscribeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class SubscriptionControllerTest : ControllerTestBase {
    void runTests() {
      auto repo = new MemorySubscriptionRepository();
      auto eventRepo = new MemoryEnvironmentEventRepository();
      auto usecase = new ManageSubscriptionsUseCase(repo, eventRepo);
      auto controller = new SubscriptionController(usecase);
      auto tenantId = TenantId("test-tenant");

      auto reqListEmpty = createMockRequest("GET", "/api/v1/subscriptions", tenantId);
      reqListEmpty.params["subaccountId"] = "sub-1";
      auto resListEmpty = controller.listHandler(reqListEmpty);
      assert(resListEmpty.getInteger("code") == 200);
      assert(resListEmpty["data"].getInteger("count") == 0);

      Json createData = Json.emptyObject
        .set("subaccountId", "sub-1")
        .set("globalAccountId", "ga-1")
        .set("appName", "demo-app")
        .set("planName", "starter")
        .set("parameters", Json.emptyObject.set("region", "eu10"))
        .set("labels", Json.emptyObject.set("team", "platform"));

      auto reqCreate = createMockRequest("POST", "/api/v1/subscriptions", tenantId, createData);
      auto resCreate = controller.subscribeHandler(reqCreate);
      assert(resCreate.getInteger("code") == 201);
      auto createdId = resCreate["data"].getString("id");
      assert(createdId.length > 0);
      assert(repo.countByTenant(tenantId) == 1);
      assert(repo.countBySubaccount(tenantId, SubaccountId("sub-1")) == 1);

      auto reqList = createMockRequest("GET", "/api/v1/subscriptions", tenantId);
      reqList.params["subaccountId"] = "sub-1";
      auto resList = controller.listHandler(reqList);
      assert(resList.getInteger("code") == 200);
      // assert(resList["data"].getInteger("count") == 1);

      auto reqGet = createMockRequest("GET", "/api/v1/subscriptions/" ~ createdId, tenantId);
      auto resGet = controller.getHandler(reqGet);
      assert(resGet.getInteger("code") == 200);
      assert(resGet["data"].getString("appName") == "demo-app");
      // assert(resGet["data"].getString("planName") == "starter");

      Json updateData = Json.emptyObject
        .set("planName", "premium")
        .set("parameters", Json.emptyObject.set("region", "us10"));
      auto reqUpdate = createMockRequest("PUT", "/api/v1/subscriptions/" ~ createdId, tenantId, updateData);
      auto resUpdate = controller.updateHandler(reqUpdate);
      assert(resUpdate.getInteger("code") == 200);

      auto resGetUpdated = controller.getHandler(reqGet);
      assert(resGetUpdated.getInteger("code") == 200);
      assert(resGetUpdated["data"].getString("planName") == "premium");
      // assert(resGetUpdated["data"]["parameters"].getString("region") == "us10");

      auto reqUnsubscribe = createMockRequest("POST", "/api/v1/subscriptions/unsubscribe/" ~ createdId, tenantId);
      auto resUnsubscribe = controller.unsubscribeHandler(reqUnsubscribe);
      assert(resUnsubscribe.getInteger("code") == 200);

      auto resUnsubscribeAgain = controller.unsubscribeHandler(reqUnsubscribe);
      assert(resUnsubscribeAgain.getInteger("code") == 400);
    }
  }

  auto runner = new SubscriptionControllerTest();
  runner.runTests();
}
