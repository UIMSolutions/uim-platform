/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.event_message;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_messages;
import uim.platform.appevents.domain.valueobjects;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class EventMessageController : ManageController {
    private ManageEventMessagesUseCase _useCase;

    this(ManageEventMessagesUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/messages",      &handleList);
        router.get("/api/v1/appevents/messages/*",    &handleGet);
        router.post("/api/v1/appevents/messages",     &handleCreate);
        router.delete_("/api/v1/appevents/messages/*",&handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto items = _useCase.listEventMessages(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Event messages retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = EventMessageId(precheck.id);
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getEventMessage(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Message not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventMessageDTO dto;
        dto.messageId      = EventMessageId(data.getString("messageId", ""));
        dto.tenantId       = tenantId;
        dto.channelId      = EventChannelId(data.getString("channelId", ""));
        dto.eventType      = data.getString("eventType", "");
        dto.payload        = data.getString("payload", "");
        dto.sourceSystemId = data.getString("sourceSystemId", "");
        dto.targetSystemId = data.getString("targetSystemId", "");
        dto.createdBy      = UserId(data.getString("createdBy", ""));
        auto result = _useCase.publishMessage(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Message published successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = EventMessageId(precheck.id);
        auto result = _useCase.deleteEventMessage(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Message deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
