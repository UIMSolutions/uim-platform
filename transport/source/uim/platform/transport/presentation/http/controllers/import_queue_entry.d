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
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = ImportQueueEntryprecheck.id);
            auto item = usecase.getEntry(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Import queue entry not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            ImportQueueEntryDTO dto;
            dto.entryId = ImportQueueEntryId(precheck.id);
            dto.tenantId = tenantId;
            dto.nodeId = data.getString("nodeId");
            dto.requestId = data.getString("requestId");
            dto.queuePosition = cast(int) j.getLong("queuePosition");
            dto.isSelected = getBoolean(j, "isSelected");
            dto.scheduledAt = j.getLong("scheduledAt");
            dto.createdBy = UserId(data.getString("createdBy"));
            auto result = usecase.enqueue(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Enqueued for import"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = ImportQueueEntryprecheck.id);
            auto data = precheck.data;
            auto action = data.getString("action");
            if (action == "reset") {
                auto result = usecase.resetEntry(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Entry reset"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            auto statusStr = data.getString("status");
            if (statusStr.length > 0) {
                import std.conv : to;
                try {
                    auto status = statusStr.to!ImportStatus;
                    auto errorMsg = data.getString("errorMessage");
                    auto result = usecase.updateEntryStatus(tenantId, id, status, errorMsg);
                    if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Status updated"), 200);
                    else writeError(res, 400, result.message);
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

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = ImportQueueEntryprecheck.id);
            auto result = usecase.deleteEntry(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Import queue entry deleted"), 200);
            else writeError(res, 404, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
