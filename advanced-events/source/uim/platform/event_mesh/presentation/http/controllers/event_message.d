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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listMessages(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Event message list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto message = usecase.getMessage(tenantId, EventMessageId(id));
            if (message.isNull) {
                writeError(res, 404, "Event message not found");
                return;
            }
            res.writeJsonBody(message.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            EventMessageDTO dto;
            dto.messageId = EventMessageId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceId = BrokerServiceId(j.getString("serviceId"));
            dto.topicId = j.getString("topicId");
            dto.queueId = j.getString("queueId");
            // TODO: dto.publisherId = j.getString("publisherId");
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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = usecase.acknowledgeMessage(tenantId, EventMessageId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Event message acknowledged");

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
            auto id = EventMessageId(extractIdFromPath(path));

            auto result = usecase.deleteMessage(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Event message deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
