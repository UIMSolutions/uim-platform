/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.subscription;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class SubscriptionController : ManageController {
    private ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/subscriptions", &handleList);
        router.get("/api/v1/event-mesh/subscriptions/*", &handleGet);
        router.post("/api/v1/event-mesh/subscriptions", &handleCreate);
        router.put("/api/v1/event-mesh/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/subscriptions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listSubscriptions(tenantId);
        auto jarr = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Subscription list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(data.getString("id"));
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("serviceId"));
        dto.topicId = TopicId(data.getString("topicId"));
        dto.queueId = QueueId(data.getString("queueId"));
        dto.applicationId = EventApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
        dto.maxTtl = data.getString("maxTtl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createSubscription(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Subscription created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto e = usecase.getSubscription(tenantId, id);
        if (e.isNull)
            return errorResponse("Subscription not found", 404);

        auto responseData = e.toJson();
        return successResponse("Subscription retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        SubscriptionDTO dto;
        dto.subscriptionId = EventSubscriptionId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.topicFilter = data.getString("topicFilter");
        dto.selector = data.getString("selector");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateSubscription(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Subscription updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = EventSubscriptionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid subscription ID", 400);

        auto result = usecase.deleteSubscription(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Subscription deleted successfully", "Deleted", 200, responseData);
    }
}
