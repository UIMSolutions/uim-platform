/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.event_filter;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.filter_type;
import uim.platform.appevents.domain.enums.filter_operator;
import std.conv  : to;
import std.array : array;
import std.algorithm : map;

@safe:

class EventFilterController : ManageController {
    private ManageEventFiltersUseCase _useCase;

    this(ManageEventFiltersUseCase useCase) { _useCase = useCase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/filters",       &handleList);
        router.get("/api/v1/appevents/filters/*",     &handleGet);
        router.post("/api/v1/appevents/filters",      &handleCreate);
        router.put("/api/v1/appevents/filters/*",     &handleUpdate);
        router.delete_("/api/v1/appevents/filters/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = _useCase.listEventFilters(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message",   "Event filters retrieved successfully")
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = EventFilterId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = _useCase.getEventFilter(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Filter not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        EventFilterDTO dto;
        dto.filterId       = EventFilterId(data.getString("filterId", ""));
        dto.tenantId       = tenantId;
        dto.subscriptionId = EventSubscriptionId(data.getString("subscriptionId", ""));
        dto.filterType     = data.getString("filterType", "include").to!FilterType;
        dto.attribute      = data.getString("attribute", "");
        dto.operator_      = data.getString("operator", "equals").to!FilterOperator;
        dto.value          = data.getString("value", "");
        dto.active         = data.getBool("active", true);
        dto.createdBy      = UserId(data.getString("createdBy", ""));
        auto result = _useCase.createEventFilter(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Filter created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        EventFilterDTO dto;
        dto.filterId       = EventFilterId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId       = tenantId;
        dto.subscriptionId = EventSubscriptionId(data.getString("subscriptionId", ""));
        dto.filterType     = data.getString("filterType", "include").to!FilterType;
        dto.attribute      = data.getString("attribute", "");
        dto.operator_      = data.getString("operator", "equals").to!FilterOperator;
        dto.value          = data.getString("value", "");
        dto.active         = data.getBool("active", true);
        dto.updatedBy      = UserId(data.getString("updatedBy", ""));
        auto result = _useCase.updateEventFilter(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Filter updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = EventFilterId(extractIdFromPath(req.requestURI.to!string));
        auto result = _useCase.deleteEventFilter(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Filter deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
