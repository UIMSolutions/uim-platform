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
class SubscriptionController : ManageController {
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

  protected void handleSubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateSubscriptionRequest r;
      r.tenantId = tenantId;
      r.subaccountId = j.getString("subaccountId");
      r.globalAccountId = j.getString("globalAccountId");
      r.appName = j.getString("appName");
      r.planName = j.getString("planName");
      r.subscribedBy = UserId(req.headers.get("X-User-Id", ""));
      r.parameters = jsonStrMap(j, "parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = usecase.subscribeSubscription(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Subscription successful");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto resourceType = req.params.get("resourceType");
      auto resourceId = req.params.get("resourceId");
      auto subId = req.params.get("subaccountId");
      Subscription[] items;
      if (!subId.isEmpty)
        items = usecase.listSubscriptions(tenantId, subId);

      auto arr = items.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Subscriptions retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto s = usecase.getSubscription(tenantId, id);
      if (s.isNull) {
        writeError(res, 404, "Subscription not found");
        return;
      }
      res.writeJsonBody(s.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubscriptionId(extractId(req.requestURI));
      auto j = req.json;
      UpdateSubscriptionRequest r;
      r.tenantId = tenantId;  
      r.planName = j.getString("planName");
      r.parameters = jsonStrMap(j, "parameters");

      auto result = usecase.updateSubscriptionPlan(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUnsubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SubscriptionId(extractId(req.requestURI));
      auto result = usecase.unsubscribeSubscription(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

