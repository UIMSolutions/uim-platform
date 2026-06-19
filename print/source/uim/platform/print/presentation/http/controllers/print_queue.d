/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_queue;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class PrintQueueController : ManageHttpController {
    private ManagePrintQueuesUseCase usecase;

    this(ManagePrintQueuesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/print/queues", &handleList);
        router.get("/api/v1/print/queues/*", &handleGet);
        router.post("/api/v1/print/queues", &handleCreate);
        router.put("/api/v1/print/queues/*", &handleUpdate);
        router.delete_("/api/v1/print/queues/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listPrintQueues(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Print queue list retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PrintQueueId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid print queue ID", 400);

        auto e = usecase.getPrintQueue(tenantId, id);
        if (e.isNull)
            return errorResponse("Print queue not found", 404);

        return successResponse("Print queue retrieved successfully", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PrintQueueDTO dto;
        dto.queueId = PrintQueueId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.printerId = data.getString("printerId");
        dto.location = data.getString("location");
        dto.costCenter = data.getString("costCenter");
        dto.isDefault = data.getBoolean("isDefault");
        dto.maxRetries = cast(int)j.getInt("maxRetries");
        dto.retentionDays = cast(int)j.getInt("retentionDays");

        auto result = usecase.createPrintQueue(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Print queue created successfully", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PrintQueueDTO dto;
        dto.queueId = PrintQueueId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.location = data.getString("location");
        dto.costCenter = data.getString("costCenter");
        dto.status = data.getString("status");

        auto result = usecase.updatePrintQueue(dto);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto resp = Json.emptyObject.set("id", result.id);

        return successResponse("Print queue updated successfully", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = PrintQueueId(precheck.id);
        auto result = usecase.deletePrintQueue(tenantId, id);
        if (result.hasError) {
            return errorResponse(result.message, 404);
        }
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Print queue deleted successfully", 200, resp);
    }
}
