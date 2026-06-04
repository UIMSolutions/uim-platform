/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.presentation.http.controllers.app_subscription;

import uim.platform.saas_provisioning;

import std.string : indexOf;
import std.array : split;

mixin(ShowModule!());

@safe:

/// REST controller — Provider and Consumer: subscription management.
///
/// Provider endpoints:
///   GET    /api/v1/saas-provisioning/subscriptions            — list all (filter by appName query param)
///   POST   /api/v1/saas-provisioning/subscriptions            — subscribe a consumer tenant
///   GET    /api/v1/saas-provisioning/subscriptions/*          — get subscription by ID
///   PATCH  /api/v1/saas-provisioning/subscriptions/*          — update state / error
///   DELETE /api/v1/saas-provisioning/subscriptions/*          — unsubscribe
class AppSubscriptionController : ManageHttpController {
    private ManageAppSubscriptionsUseCase usecase;

    this(ManageAppSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get(    "/api/v1/saas-provisioning/subscriptions",   &handleList);
        router.post(   "/api/v1/saas-provisioning/subscriptions",   &handleSubscribe);
        router.get(    "/api/v1/saas-provisioning/subscriptions/*", &handleGet);
        router.put(    "/api/v1/saas-provisioning/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/saas-provisioning/subscriptions/*", &handleUnsubscribe);
    }

    // -----------------------------------------------------------------------

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            AppSubscription[] subs;

            // Optional ?appName=... filter
            string appName = "";
            foreach (kv; req.query.byKeyValue()) {
                if (kv.key == "appName") { appName = kv.value; break; }
            }

            subs = (appName.length > 0)
                ? usecase.listForApp(tenantId, appName)
                : usecase.listAll(tenantId);

            auto arr = Json.emptyArray;
            foreach (s; subs) arr ~= s.toJson();
            res.writeJsonBody(
                Json.emptyObject.set("count", subs.length).set("subscriptions", arr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto body_    = req.json;

            SubscribeRequest dto;
            dto.subscriberTenantId        = safeStr(body_, "subscriberTenantId");
            dto.subscriberSubaccountId    = safeStr(body_, "subscriberSubaccountId");
            dto.subscriberGlobalAccountId = safeStr(body_, "subscriberGlobalAccountId");
            dto.subdomain                 = safeStr(body_, "subdomain");
            dto.subscribedBy              = safeStr(body_, "subscribedBy");
            string appName                = safeStr(body_, "appName");

            auto result = usecase.subscribeConsumer(tenantId, appName, dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("subscriptionId", result.id), 201);
        } catch (Exception e) {
            writeError(res, 400, "Invalid request: " ~ e.msg);
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = AppSubscriptionId(precheck.id);
            auto sub = usecase.getSubscription(tenantId, id);
            if (sub.isNull) { writeError(res, 404, "Subscription not found"); return; }
            res.writeJsonBody(sub.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id       = AppSubscriptionId(precheck.id);
            auto body_    = req.json;

            UpdateSubscriptionRequest dto;
            if ((("state" in body_) !is null) && body_["state"].isString) {
                try { dto.state = body_["state"].get!string.to!SubscriptionState; } catch (Exception) {}
            }
            dto.error = safeStr(body_, "error");

            auto result = usecase.updateSubscription(tenantId, id, dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
        } catch (Exception e) {
            writeError(res, 400, "Invalid request: " ~ e.msg);
        }
    }

    protected void handleUnsubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId    = tenantId;
            auto id          = AppSubscriptionId(precheck.id);
            string requestedBy = "";
            try { requestedBy = safeStr(req.json, "requestedBy"); } catch (Exception) {}
            auto result = usecase.unsubscribeConsumer(tenantId, id, requestedBy);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // -----------------------------------------------------------------------

    private string safeStr(Json obj, string key) {
        if ((key in obj) !is null && obj[key].isString) return obj[key].get!string;
        return "";
    }
}
