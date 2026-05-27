/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.presentation.http.controllers.mta_subscription;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// REST /api/v1/slm/subscriptions — subscribe/unsubscribe/list MTA subscriptions.
class MtaSubscriptionController : ManageController {
    private ManageMtaSubscriptionsUseCase usecase;

    this(ManageMtaSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/slm/subscriptions",       &handleList);
        router.get("/api/v1/slm/subscriptions/*",      &handleGet);
        router.post("/api/v1/slm/subscriptions",      &handleSubscribe);
        router.delete_("/api/v1/slm/subscriptions/*", &handleUnsubscribe);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto subs = usecase.listSubscriptions(tenantId);
            auto arr = Json.emptyArray;
            foreach (s; subs) arr ~= s.toJson;
            res.writeJsonBody(
                Json.emptyObject.set("count", subs.length).set("subscriptions", arr),
                200
            );
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = MtaSubscriptionprecheck.id);
            auto s = usecase.getSubscription(tenantId, id);
            if (s.isNull) { writeError(res, 404, "Subscription not found"); return; }
            res.writeJsonBody(s.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SubscribeMtaRequest r;
            r.tenantId            = req.getTenantId;
            r.providerMtaId       = data.getString("providerMtaId");
            r.providerTenantId    = data.getString("providerTenantId");
            r.providerSpaceId     = data.getString("providerSpaceId");
            r.subscribedBy        = data.getString("subscribedBy");
            r.extensionDescriptor = data.getString("extensionDescriptor");

            auto result = usecase.subscribe(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(
                    Json.emptyObject
                        .set("operationId", result.id)
                        .set("message", "Subscribe operation started"),
                    202
                );
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUnsubscribe(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            UnsubscribeMtaRequest r;
            r.tenantId        = req.getTenantId;
            r.subscriptionId  = extractIdFromPath(req.requestURI.to!string);
            r.unsubscribedBy  = req.json.getString("unsubscribedBy");

            auto result = usecase.unsubscribe(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(
                    Json.emptyObject
                        .set("operationId", result.id)
                        .set("message", "Unsubscribe operation started"),
                    202
                );
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
