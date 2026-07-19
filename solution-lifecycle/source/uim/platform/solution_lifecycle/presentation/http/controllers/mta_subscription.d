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
class MtaSubscriptionController : ManageHttpController {
    private ManageMtaSubscriptionsUseCase usecase;

    this(ManageMtaSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/slm/subscriptions", &handleList);
        router.get("/api/v1/slm/subscriptions/*", &handleGet);
        router.post("/api/v1/slm/subscriptions", &handleSubscribe);
        router.delete_("/api/v1/slm/subscriptions/*", &handleUnsubscribe);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto subs = usecase.listSubscriptions(tenantId).map!(s => s.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", subs.length)
            .set("resources", subs);
        return successResponse("Subscription list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MtaSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto s = usecase.getSubscription(tenantId, id);
        if (s.isNull)
            return errorResponse("Subscription not found", 404);

        return successResponse("Subscription retrieved successfully", "Retrieved", 200, s.toJson);
    }

    protected Json subscribeHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        SubscribeMtaRequest r;
        r.tenantId = tenantId;
        r.providerMtaId = data.getString("providerMtaId");
        r.providerTenantId = data.getString("providerTenantId");
        r.providerSpaceId = data.getString("providerSpaceId");
        r.subscribedBy = data.getString("subscribedBy");
        r.extensionDescriptor = data.getString("extensionDescriptor");

        auto result = usecase.subscribe(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("operationId", result.id)
            .set("message", "Subscribe operation started");
        return successResponse("Subscribe operation started", "Started", 202, resp);
    } 

    mixin(HandleTemplate!("handleSubscribe", "subscribeHandler"));

    protected Json unsubscribeHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MtaSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        UnsubscribeMtaRequest r;
        r.tenantId = tenantId;
        r.subscriptionId = id;
        r.unsubscribedBy = precheck.data.getString("unsubscribedBy");

        auto result = usecase.unsubscribe(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("operationId", result.id)
            .set("message", "Unsubscribe operation started");
        return successResponse("Unsubscribe operation started", "Started", 202, resp);
    }

    mixin(HandleTemplate!("handleUnsubscribe", "unsubscribeHandler"));
}
