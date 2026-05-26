/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.queue;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class QueueController : ManageController {
    private ManageQueuesUseCase usecase;

    this(ManageQueuesUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/queues",    &handleList);
        router.get("/api/v1/sap-event-mesh/queues/*",  &handleGet);
        router.post("/api/v1/sap-event-mesh/queues",   &handleCreate);
        router.put("/api/v1/sap-event-mesh/queues/*",  &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/queues/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listQueues(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Queue list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = precheck.id;
            auto e = usecase.getQueue(tenantId, QueueId(id));
            if (e.isNull) { writeError(res, 404, "Queue not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Queue retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            QueueDTO dto;
            dto.queueId            = QueueId(j.getString("id"));
            dto.tenantId           = tenantId;
            dto.serviceId          = MessagingServiceId(j.getString("serviceId"));
            dto.name               = j.getString("name");
            dto.description        = j.getString("description");
            dto.maxMessageSizeBytes = j.getString("maxMessageSizeBytes");
            dto.maxQueueSizeBytes  = j.getString("maxQueueSizeBytes");
            dto.maxConsumers       = j.getString("maxConsumers");
            dto.deadLetterQueue    = j.getString("deadLetterQueue");
            dto.discardMessages    = j.getString("discardMessages");
            dto.maxRedeliveryCount = j.getString("maxRedeliveryCount");
            dto.messageExpiryTimer = j.getString("messageExpiryTimer");
            dto.owner              = j.getString("owner");
            dto.permission         = j.getString("permission");
            dto.egressEnabled      = j.getBool("egressEnabled");
            dto.ingressEnabled     = j.getBool("ingressEnabled");
            dto.createdBy          = UserId(j.getString("createdBy"));
            auto result = usecase.createQueue(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue created"), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto queueId  = Queueprecheck.id);
            auto j = req.json;
            QueueDTO dto;
            dto.tenantId           = tenantId;
            dto.queueId            = queueId;
            dto.description        = j.getString("description");
            dto.maxMessageSizeBytes = j.getString("maxMessageSizeBytes");
            dto.maxQueueSizeBytes  = j.getString("maxQueueSizeBytes");
            dto.maxConsumers       = j.getString("maxConsumers");
            dto.deadLetterQueue    = j.getString("deadLetterQueue");
            dto.maxRedeliveryCount = j.getString("maxRedeliveryCount");
            dto.updatedBy          = UserId(j.getString("updatedBy"));
            auto result = usecase.updateQueue(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue updated"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = Queueprecheck.id);
            auto result = usecase.deleteQueue(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Queue deleted"), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
