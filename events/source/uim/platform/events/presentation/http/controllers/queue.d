/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.queue;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class QueueController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listQueues(tenantId);
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson)
                .set("message", "Queue list retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getQueue(tenantId, QueueId(id));
            if (e.isNull) { writeError(res, 404, "Queue not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("message", "Queue retrieved successfully")
                .set("resource", e.toJson), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            QueueDTO dto;
            dto.queueId            = QueueId(precheck.id);
            dto.tenantId           = tenantId;
            dto.serviceId          = MessagingServiceId(data.getString("serviceId"));
            dto.name               = data.getString("name");
            dto.description        = data.getString("description");
            dto.maxMessageSizeBytes = data.getString("maxMessageSizeBytes");
            dto.maxQueueSizeBytes  = data.getString("maxQueueSizeBytes");
            dto.maxConsumers       = data.getString("maxConsumers");
            dto.deadLetterQueue    = data.getString("deadLetterQueue");
            dto.discardMessages    = data.getString("discardMessages");
            dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
            dto.messageExpiryTimer = data.getString("messageExpiryTimer");
            dto.owner              = data.getString("owner");
            dto.permission         = data.getString("permission");
            dto.egressEnabled      = data.getBoolean("egressEnabled");
            dto.ingressEnabled     = data.getBoolean("ingressEnabled");
            dto.createdBy          = UserId(data.getString("createdBy"));
            auto result = usecase.createQueue(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue created successfully", 201, responseData);
    }


    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto queueId  = QueueId(precheck.id);
            auto data = precheck.data;
            QueueDTO dto;
            dto.tenantId           = tenantId;
            dto.queueId            = queueId;
            dto.description        = data.getString("description");
            dto.maxMessageSizeBytes = data.getString("maxMessageSizeBytes");
            dto.maxQueueSizeBytes  = data.getString("maxQueueSizeBytes");
            dto.maxConsumers       = data.getString("maxConsumers");
            dto.deadLetterQueue    = data.getString("deadLetterQueue");
            dto.maxRedeliveryCount = data.getString("maxRedeliveryCount");
            dto.updatedBy          = UserId(data.getString("updatedBy"));
            auto result = usecase.updateQueue(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue updated successfully", 200, responseData);
    }


    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = QueueId(precheck.id);
            auto result = usecase.deleteQueue(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Queue deleted successfully", 200, responseData);
    }
}
