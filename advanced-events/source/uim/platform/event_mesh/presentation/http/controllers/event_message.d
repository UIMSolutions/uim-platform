/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_message;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventMessageController : ManageController {
    private ManageEventMessagesUseCase usecase;

    this(ManageEventMessagesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/messages", &handleList);
        router.get("/api/v1/event-mesh/messages/*", &handleGet);
        router.post("/api/v1/event-mesh/messages", &handlePublish);
        router.put("/api/v1/event-mesh/messages/*/acknowledge", &handleAcknowledge);
        router.delete_("/api/v1/event-mesh/messages/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listMessages(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Event message list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = EventMessageId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid message ID", 400);

        auto message = usecase.getMessage(tenantId, id);
        if (message.isNull)
            return errorResponse("Event message not found", 404);

        auto responseData = job.toJson();

        return successResponse("");
    }

    protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;

            EventMessageDTO dto;
            dto.messageId = EventMessageId(precheck.id);
            dto.tenantId = tenantId;
            dto.serviceId = BrokerServiceId(j.getString("serviceId"));
            dto.topicId = j.getString("topicId");
            dto.queueId = j.getString("queueId"); // TODO: dto.publisherId = j.getString("publisherId");
            dto.correlationId = j.getString("correlationId");
            dto.contentType = j.getString("contentType");
            dto.payload = j.getString("payload");
            dto.topicString = j.getString("topicString");
            dto.replyTo = j.getString("replyTo");
            dto.timeToLive = j.getString("timeToLive");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.publishMessage(dto);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Event message published");

            if (result.success) {
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req
                .requestURI.to!string;
            auto id = EventMessageId(precheck.id);
            auto result = usecase.acknowledgeMessage(
                tenantId,
                id);
            if (result.hasError)
                return errorResponse(result.message, 400);
            auto resp = Json.emptyObject
                .set("message", "Event message acknowledged");

            if (result.success) {
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = EventMessageId(
            extractIdFromPath(path));
        auto result = usecase.deleteMessage(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json
            .emptyObject
            .set("message", "Event message deleted");

        return successResponse("Event message deleted successfully", "Deleted", 200, resp);
    }
}
