/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.event_topic;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_topics;
import uim.platform.appevents.domain.valueobjects;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class EventTopicController : ManageController {
    private ManageEventTopicsUseCase _useCase;

    this(ManageEventTopicsUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/topics",       &handleList);
        router.get("/api/v1/appevents/topics/*",     &handleGet);
        router.post("/api/v1/appevents/topics",      &handleCreate);
        router.put("/api/v1/appevents/topics/*",     &handleUpdate);
        router.delete_("/api/v1/appevents/topics/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto items = _useCase.listEventTopics(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Event topics retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto id = EventTopicId(precheck.id);
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getEventTopic(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Topic not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventTopicDTO dto;
        dto.topicId     = EventTopicId(data.getString("topicId", ""));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.namespace   = data.getString("namespace", "");
        dto.description = data.getString("description", "");
        dto.version_    = data.getString("version", "1.0.0");
        dto.category    = data.getString("category", "");
        dto.ownerId     = data.getString("ownerId", "");
        dto.createdBy   = UserId(data.getString("createdBy", ""));
        auto result = _useCase.createEventTopic(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Topic created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventTopicDTO dto;
        dto.topicId     = EventTopicId(precheck.id);
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.namespace   = data.getString("namespace", "");
        dto.description = data.getString("description", "");
        dto.version_    = data.getString("version", "");
        dto.category    = data.getString("category", "");
        dto.ownerId     = data.getString("ownerId", "");
        dto.updatedBy   = UserId(data.getString("updatedBy", ""));
        auto result = _useCase.updateEventTopic(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Topic updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = precheck.tenantId;
        auto id = EventTopicId(precheck.id);
        auto result = _useCase.deleteEventTopic(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Topic deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
