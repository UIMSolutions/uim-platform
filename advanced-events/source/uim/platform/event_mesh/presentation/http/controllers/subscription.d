/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.subscription;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class SubscriptionController : PlatformController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listSubscriptions(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventSubscriptionId(extractIdFromPath(path));

            auto e = usecase.getSubscription(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Subscription not found");
                return;
            }

            res.writeJsonBody(e.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            SubscriptionDTO dto;
            dto.subscriptionId = EventSubscriptionId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceId = BrokerServiceId(j.getString("serviceId"));
            dto.topicId = TopicId(j.getString("topicId"));
            dto.queueId = QueueId(j.getString("queueId"));
            dto.applicationId = EventApplicationId(j.getString("applicationId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicFilter = j.getString("topicFilter");
            dto.selector = j.getString("selector");
            dto.maxRedeliveryCount = j.getString("maxRedeliveryCount");
            dto.maxTtl = j.getString("maxTtl");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createSubscription(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Subscription created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            SubscriptionDTO dto;
            dto.subscriptionId = EventSubscriptionId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicFilter = j.getString("topicFilter");
            dto.selector = j.getString("selector");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateSubscription(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Subscription updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventSubscriptionId(extractIdFromPath(path));

            auto result = usecase.deleteSubscription(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Subscription deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
