/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_message;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventMessageController : PlatformController {
    private ManageEventMessagesUseCase uc;

    this(ManageEventMessagesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/messages", &handleList);
        router.get("/api/v1/event-mesh/messages/*", &handleGet);
        router.post("/api/v1/event-mesh/messages", &handlePublish);
        router.put("/api/v1/event-mesh/messages/*/acknowledge", &handleAcknowledge);
        router.delete_("/api/v1/event-mesh/messages/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= eventMessageToJson(e);
            auto resp = Json.emptyObject
              .set("count", Json(items.length))
              .set("resources", jarr)
              .set("message", Json("Event message list retrieved successfully"));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(EventMessageId(id));
            if (e.isNull) { writeError(res, 404, "Event message not found"); return; }
            res.writeJsonBody(eventMessageToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            EventMessageDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.brokerServiceId = j.getString("brokerServiceId");
            dto.topicId = j.getString("topicId");
            dto.queueId = j.getString("queueId");
            dto.publisherId = j.getString("publisherId");
            dto.correlationId = j.getString("correlationId");
            dto.contentType = j.getString("contentType");
            dto.payload = j.getString("payload");
            dto.topicString = j.getString("topicString");
            dto.replyTo = j.getString("replyTo");
            dto.timeToLive = j.getString("timeToLive");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.publish(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Event message published"));

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.acknowledge(EventMessageId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Event message acknowledged"));
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(EventMessageId(id));
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Event message deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
