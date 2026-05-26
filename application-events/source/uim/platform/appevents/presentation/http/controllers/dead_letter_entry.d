/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.http.controllers.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import std.conv : to;
import std.array : array;
import std.algorithm : map;

@safe:

class DeadLetterEntryController : ManageController {
    private ManageDeadLetterEntriesUseCase _useCase;

    this(ManageDeadLetterEntriesUseCase useCase) {
        _useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/appevents/dead-letters", &handleList);
        router.get("/api/v1/appevents/dead-letters/*", &handleGet);
        router.post("/api/v1/appevents/dead-letters", &handleCreate);
        router.delete_("/api/v1/appevents/dead-letters/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);

        auto tenantId = precheck.tenantId;
        auto items = _useCase.listDeadLetterEntries(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Dead letter entries retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);
        auto tenantId = precheck.tenantId;

        auto id = DeadLetterEntryprecheck.id);
        if (id.isNull)
            return errorResponse("Invalid Dead Letter Entry ID", 400);

        auto e = _useCase.getDeadLetterEntry(tenantId, id);
        if (e.isNull)
            return errorResponse("Dead letter entry not found", 404);
        
        return Json.emptyObject
            .set("item", e.toJson())
            .set("message", "Dead letter entry retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        
        auto id = DeadLetterEntryId(data.getString("entryId"));
        if (id.isNull)
            return errorResponse("Invalid Dead Letter Entry ID", 400);

        DeadLetterEntryDTO dto;
        dto.entryId = id;
        dto.tenantId = tenantId;
        dto.originalMessageId = EventMessageId(data.getString("originalMessageId", ""));
        dto.channelId = EventChannelId(data.getString("channelId", ""));
        dto.errorMessage = data.getString("errorMessage", "");
        dto.failedAt = data.getLong("failedAt", 0);
        dto.createdBy = data.getCreatedBy;
        dto.updatedBy = data.getUpdatedBy;
        auto result = _useCase.createDeadLetterEntry(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return Json.emptyObject.set("id", result.id).set("message", "Dead letter entry created successfully").set(
            "status", "success").set("statusCode", 201);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);
        auto tenantId = precheck.tenantId;
        auto id = DeadLetterEntryprecheck.id);
        auto result = _useCase.deleteDeadLetterEntry(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);
        return Json.emptyObject.set("id", result.id).set("message", "Dead letter entry deleted successfully").set(
            "status", "success").set("statusCode", 200);
    }
}
