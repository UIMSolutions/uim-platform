/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.subscription;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.subscriptions;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class SubscriptionController : PlatformController {
  private ManageSubscriptionsUseCase uc;

  this(ManageSubscriptionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/subscriptions", &handleSubscribe);
    router.get("/api/v1/subscriptions", &handleList);
    router.get("/api/v1/subscriptions/*", &handleGet);
    router.put("/api/v1/subscriptions/*", &handleUpdate);
    router.post("/api/v1/subscriptions/unsubscribe/*", &handleUnsubscribe);
  }

  private void handleSubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSubscriptionRequest r;
      r.subaccountId = j.getString("subaccountId");
      r.globalAccountId = j.getString("globalAccountId");
      r.appName = j.getString("appName");
      r.planName = j.getString("planName");
      r.subscribedBy = req.headers.get("X-User-Id", "");
      r.parameters = jsonStrMap(j, "parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = uc.subscribe(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto subId = req.params.get("subaccountId");
      Subscription[] items;
      if (subId.length > 0)
        items = uc.listBySubaccount(subId);

      auto arr = items.map!(s => serializeSubscription(s)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto s = uc.getById(id);
      if (s.isNull) {
        writeError(res, 404, "Subscription not found");
        return;
      }
      res.writeJsonBody(s.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateSubscriptionRequest r;
      r.planName = j.getString("planName");
      r.parameters = jsonStrMap(j, "parameters");

      auto result = uc.updatePlan(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUnsubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.unsubscribe(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeSubscription(Subscription s) {
  return Json.emptyObject
    .set("id", s.id)
    .set("subaccountId", s.subaccountId)
    .set("globalAccountId", s.globalAccountId)
    .set("appName", s.appName)
    .set("appDisplayName", s.appDisplayName)
    .set("planName", s.planName)
    .set("status", to!string(s.status))
    .set("appUrl", s.appUrl)
    .set("tenantId", s.tenantId)
    .set("isSubscriptionDone", s.isSubscriptionDone)
    .set("subscribedAt", s.subscribedAt)
    .set("updatedAt", s.updatedAt)
    .set("subscribedBy", s.subscribedBy)
    .set("parameters", s.parameters)
    .set("labels", s.labels);
}
