/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.queue_subscription;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class QueueSubscriptionController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listSubscriptions(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Queue subscription list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getSubscription(tenantId, QueueSubscriptionId(id));
            if (e.isNull) { writeError(res, 404, "Queue subscription not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Queue subscription retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            QueueSubscriptionDTO dto;
            dto.subscriptionId = QueueSubscriptionId(precheck.id);
            dto.tenantId       = tenantId;
            dto.queueId        = QueueId(data.getString("queueId"));
            dto.serviceId      = MessagingServiceId(data.getString("serviceId"));
            dto.name           = data.getString("name");
            dto.description    = data.getString("description");
            dto.topicPattern   = data.getString("topicPattern");
            dto.namespace      = data.getString("namespace");
            dto.createdBy      = UserId(data.getString("createdBy"));
            auto result = usecase.createSubscription(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto tenantId      = req.getTenantId;
            auto subscriptionId = QueueSubscriptionId(precheck.id);
            auto data = precheck.data;
            QueueSubscriptionDTO dto;
            dto.tenantId       = tenantId;
            dto.subscriptionId = subscriptionId;
            dto.description    = data.getString("description");
            dto.topicPattern   = data.getString("topicPattern");
            dto.namespace      = data.getString("namespace");
            dto.updatedBy      = UserId(data.getString("updatedBy"));
            auto result = usecase.updateSubscription(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = QueueSubscriptionId(precheck.id);
            auto result = usecase.deleteSubscription(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue subscription deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
