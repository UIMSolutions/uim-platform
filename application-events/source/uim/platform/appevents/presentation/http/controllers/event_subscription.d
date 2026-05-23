/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.event_subscription;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_subscriptions;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class EventSubscriptionController : ManageController {
    private ManageEventSubscriptionsUseCase _useCase;

    this(ManageEventSubscriptionsUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/subscriptions",       &handleList);
        router.get("/api/v1/appevents/subscriptions/*",     &handleGet);
        router.post("/api/v1/appevents/subscriptions",      &handleCreate);
        router.put("/api/v1/appevents/subscriptions/*",     &handleUpdate);
        router.delete_("/api/v1/appevents/subscriptions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = _useCase.listEventSubscriptions(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Event subscriptions retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = EventSubscriptionId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getEventSubscription(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Subscription not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;
        EventSubscriptionDTO dto;
        dto.subscriptionId    = EventSubscriptionId(data.getString("subscriptionId", ""));
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.producerSystemId  = data.getString("producerSystemId", "");
        dto.consumerSystemId  = data.getString("consumerSystemId", "");
        dto.eventType         = data.getString("eventType", "");
        dto.formationId       = FormationId(data.getString("formationId", ""));
        dto.filterExpression  = data.getString("filterExpression", "");
        dto.maxRetries        = cast(int) data.getLong("maxRetries", 3);
        dto.createdBy         = UserId(data.getString("createdBy", ""));
        auto result = _useCase.createEventSubscription(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Subscription created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;
        EventSubscriptionDTO dto;
        dto.subscriptionId    = EventSubscriptionId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.producerSystemId  = data.getString("producerSystemId", "");
        dto.consumerSystemId  = data.getString("consumerSystemId", "");
        dto.eventType         = data.getString("eventType", "");
        dto.formationId       = FormationId(data.getString("formationId", ""));
        dto.filterExpression  = data.getString("filterExpression", "");
        dto.maxRetries        = cast(int) data.getLong("maxRetries", 3);
        dto.updatedBy         = UserId(data.getString("updatedBy", ""));
        auto result = _useCase.updateEventSubscription(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Subscription updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = EventSubscriptionId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteEventSubscription(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Subscription deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
