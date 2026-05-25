/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.event_channel;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_type;
import uim.platform.appevents.domain.enums.channel_status;
import uim.platform.appevents.domain.enums.delivery_mode;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class EventChannelController : ManageController {
    private ManageEventChannelsUseCase _useCase;

    this(ManageEventChannelsUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/channels",       &handleList);
        router.get("/api/v1/appevents/channels/*",     &handleGet);
        router.post("/api/v1/appevents/channels",      &handleCreate);
        router.put("/api/v1/appevents/channels/*",     &handleUpdate);
        router.delete_("/api/v1/appevents/channels/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto items = _useCase.listEventChannels(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Event channels retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getEventChannel(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Channel not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventChannelDTO dto;
        dto.channelId    = EventChannelId(data.getString("channelId", ""));
        dto.tenantId     = tenantId;
        dto.name         = data.getString("name", "");
        dto.topicId      = EventTopicId(data.getString("topicId", ""));
        dto.channelType  = data.getString("channelType", "queue").to!ChannelType;
        dto.endpoint     = data.getString("endpoint", "");
        dto.deliveryMode = data.getString("deliveryMode", "atLeastOnce").to!DeliveryMode;
        dto.maxSizeBytes = data.getLong("maxSizeBytes", 1_048_576);
        dto.createdBy    = UserId(data.getString("createdBy", ""));
        auto result = _useCase.createEventChannel(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Channel created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventChannelDTO dto;
        dto.channelId    = EventChannelId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId     = tenantId;
        dto.name         = data.getString("name", "");
        dto.topicId      = EventTopicId(data.getString("topicId", ""));
        dto.channelType  = data.getString("channelType", "queue").to!ChannelType;
        dto.endpoint     = data.getString("endpoint", "");
        dto.deliveryMode = data.getString("deliveryMode", "atLeastOnce").to!DeliveryMode;
        dto.maxSizeBytes = data.getLong("maxSizeBytes", 0);
        dto.updatedBy    = UserId(data.getString("updatedBy", ""));
        auto result = _useCase.updateEventChannel(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Channel updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto id = EventChannelId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteEventChannel(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Channel deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
