/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ImportQueueEntryController : ManageController {
    private ManageImportQueueEntriesUseCase usecase;

    this(ManageImportQueueEntriesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/queue-entries", &handleList);
        router.get("/api/v1/transport/queue-entries/*", &handleGet);
        router.post("/api/v1/transport/queue-entries", &handleCreate);
        router.put("/api/v1/transport/queue-entries/*", &handleUpdate);
        router.delete_("/api/v1/transport/queue-entries/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listEntries(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Import queue entries retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ImportQueueEntryId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid entry ID", 400);

        auto item = usecase.getEntry(tenantId, id);
        if (item.isNull)
            return errorResponse("Job not found", 404);

        auto responseData = item.toJson();
        return successResponse("Import queue entry retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ImportQueueEntryDTO dto;
        dto.entryId = ImportQueueEntryId(precheck.id);
        dto.tenantId = tenantId;
        dto.nodeId = data.getString("nodeId");
        dto.requestId = data.getString("requestId");
        dto.queuePosition = data.getInteger("queuePosition");
        dto.isSelected = data.getBoolean("isSelected");
        dto.scheduledAt = data.getLong("scheduledAt");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.enqueue(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Import queue entry created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ImportQueueEntryId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid entry ID", 400);

        auto data = precheck.data;
        auto action = data.getString("action");
        if (action == "reset") {
            auto result = usecase.resetEntry(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Import queue entry reset successfully", "Reset", 200, responseData);
        }
        auto statusStr = data.getString("status");
        if (statusStr.length > 0) {
            import std.conv : to;

            try {
                auto status = statusStr.to!ImportStatus;
                auto errorMsg = data.getString("errorMessage");
                auto result = usecase.updateEntryStatus(tenantId, id, status, errorMsg);
                if (result.hasError)
                    return errorResponse(result.message, 400);

                auto responseData = Json.emptyObject.set("id", result.id);
                return successResponse("Import queue entry status updated successfully", "Updated", 200, responseData);
            }
        }
        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Import queue entry updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ImportQueueEntryId(precheck.id);
        auto result = usecase.deleteEntry(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Import queue entry deleted successfully", "Deleted", 200, responseData);
    }
}
