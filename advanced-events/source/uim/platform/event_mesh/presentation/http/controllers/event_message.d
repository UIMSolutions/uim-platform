/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_message;

import std.uuid : randomUUID;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class EventMessageController : ManageHttpController {
    private ManageEventMessagesUseCase usecase;

    this(ManageEventMessagesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/messages", &handleList);
        router.get("/api/v1/event-mesh/messages/*", &handleGet);
        router.post("/api/v1/event-mesh/messages", &handlePublish);
        // router.put("/api/v1/event-mesh/messages/*/acknowledge", &handleAcknowledge);
        router.delete_("/api/v1/event-mesh/messages/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listMessages(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

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

        auto responseData = message.toJson();

        return successResponse("Event message retrieved successfully", "Retrieved", 200, responseData);
    }

    protected Json publishHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        auto createId = precheck.id;
        if (createId.isEmpty)
            createId = data.getString("id");
        if (createId.isEmpty) {
            try {
                createId = req.params["id"];
            } catch (Exception) {
            }
        }
        if (createId.isEmpty)
            createId = randomUUID().toString();

        EventMessageDTO dto;
        dto.messageId = EventMessageId(createId);
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("serviceId"));
        dto.topicId = data.getString("topicId");
        dto.queueId = data.getString("queueId"); // TODO: dto.publisherId = data.getString("publisherId");
        dto.correlationId = data.getString("correlationId");
        dto.contentType = data.getString("contentType");
        dto.payload = data.getString("payload");
        dto.topicString = data.getString("topicString");
        dto.replyTo = data.getString("replyTo");
        dto.timeToLive = data.getString("timeToLive");
        dto.createdBy = UserId(data.getString("createdBy"));
        auto result = usecase.publishMessage(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Event message published");

        return successResponse("Event message published successfully", "Published", 201, resp);
    }

    mixin(HandleTemplate!("handlePublish", "publishHandler"));

    protected Json acknowledgeHandler(HTTPServerRequest req) {
        auto precheck = super.putHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = EventMessageId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid message ID", 400);

        auto result = usecase.acknowledgeMessage(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("message", "Event message acknowledged");

        return successResponse("Event message acknowledged successfully", "Acknowledged", 200, resp);
    }

    mixin(HandleTemplate!("handleAcknowledge", "acknowledgeHandler"));

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
