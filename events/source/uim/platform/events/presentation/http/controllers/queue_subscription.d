/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.queue_subscription;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class QueueSubscriptionController : PlatformController {
    private ManageQueueSubscriptionsUseCase usecase;

    this(ManageQueueSubscriptionsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/queue-subscriptions",    &handleList);
        router.get("/api/v1/sap-event-mesh/queue-subscriptions/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/queue-subscriptions",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/queue-subscriptions/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/queue-subscriptions/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listSubscriptions(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Queue subscription list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = usecase.getSubscription(tenantId, QueueSubscriptionId(id));
            if (e.isNull) { writeError(res, 404, "Queue subscription not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Queue subscription retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            QueueSubscriptionDTO dto;
            dto.subscriptionId = QueueSubscriptionId(j.getString("id"));
            dto.tenantId       = tenantId;
            dto.queueId        = QueueId(j.getString("queueId"));
            dto.serviceId      = MessagingServiceId(j.getString("serviceId"));
            dto.name           = j.getString("name");
            dto.description    = j.getString("description");
            dto.topicPattern   = j.getString("topicPattern");
            dto.namespace      = j.getString("namespace");
            dto.createdBy      = UserId(j.getString("createdBy"));
            auto result = usecase.createSubscription(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription created"), 201);
            } else { writeError(res, 400, result.errorMessage); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId      = req.getTenantId;
            auto subscriptionId = QueueSubscriptionId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            QueueSubscriptionDTO dto;
            dto.tenantId       = tenantId;
            dto.subscriptionId = subscriptionId;
            dto.description    = j.getString("description");
            dto.topicPattern   = j.getString("topicPattern");
            dto.namespace      = j.getString("namespace");
            dto.updatedBy      = UserId(j.getString("updatedBy"));
            auto result = usecase.updateSubscription(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription updated"), 200);
            } else { writeError(res, 404, result.errorMessage); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = QueueSubscriptionId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteSubscription(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription deleted"), 200);
            } else { writeError(res, 404, result.errorMessage); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
