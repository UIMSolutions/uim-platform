/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ImportQueueEntryController : PlatformController {
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

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listEntries(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ImportQueueEntryId(extractIdFromPath(req.requestURI.to!string));
            auto item = usecase.getEntry(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Import queue entry not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ImportQueueEntryDTO dto;
            dto.entryId = ImportQueueEntryId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.nodeId = j.getString("nodeId");
            dto.requestId = j.getString("requestId");
            dto.queuePosition = cast(int) getLong(j, "queuePosition");
            dto.isSelected = getBoolean(j, "isSelected");
            dto.scheduledAt = j.getString("scheduledAt");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.enqueue(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Enqueued for import"), 201);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ImportQueueEntryId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            auto action = j.getString("action");
            if (action == "reset") {
                auto result = usecase.resetEntry(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Entry reset"), 200);
                else writeError(res, 400, result.error);
                return;
            }
            auto statusStr = j.getString("status");
            if (statusStr.length > 0) {
                import std.conv : to;
                try {
                    auto status = statusStr.to!ImportStatus;
                    auto errorMsg = j.getString("errorMessage");
                    auto result = usecase.updateEntryStatus(tenantId, id, status, errorMsg);
                    if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Status updated"), 200);
                    else writeError(res, 400, result.error);
                } catch (Exception) {
                    writeError(res, 400, "Invalid status value");
                }
            } else {
                writeError(res, 400, "action or status field is required");
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ImportQueueEntryId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteEntry(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Import queue entry deleted"), 200);
            else writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
