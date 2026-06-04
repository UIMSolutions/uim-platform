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
// import uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());
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
