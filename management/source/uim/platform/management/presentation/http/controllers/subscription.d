module uim.platform.management.presentation.http.controllers.subscription;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage_subscriptions;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.types;
// import presentation.http.json_utils;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class SubscriptionController {
    private ManageSubscriptionsUseCase uc;

    this(ManageSubscriptionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
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
            auto subId = req.params.get("subaccountId");
            Subscription[] items;
            if (subId.length > 0)
                items = uc.listBySubaccount(subId);

            auto arr = Json.emptyArray;
            foreach (ref s; items)
                arr ~= serializeSubscription(s);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto s = uc.getById(id);
            if (s.id.length == 0) {
                writeError(res, 404, "Subscription not found");
                return;
            }
            res.writeJsonBody(serializeSubscription(s), 200);
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

private Json serializeSubscription(ref Subscription s) {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["subaccountId"] = Json(s.subaccountId);
    j["globalAccountId"] = Json(s.globalAccountId);
    j["appName"] = Json(s.appName);
    j["appDisplayName"] = Json(s.appDisplayName);
    j["planName"] = Json(s.planName);
    j["status"] = Json(enumStr(s.status));
    j["appUrl"] = Json(s.appUrl);
    j["tenantId"] = Json(s.tenantId);
    j["isSubscriptionDone"] = Json(s.isSubscriptionDone);
    j["subscribedAt"] = Json(s.subscribedAt);
    j["modifiedAt"] = Json(s.modifiedAt);
    j["subscribedBy"] = Json(s.subscribedBy);
    j["parameters"] = serializeStrMap(s.parameters);
    j["labels"] = serializeStrMap(s.labels);
    return j;
}

private string enumStr(E)(E val) {
    import std.conv : to;

    return val.to!string;
}
