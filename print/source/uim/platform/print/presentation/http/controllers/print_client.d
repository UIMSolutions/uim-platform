/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_client;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class PrintClientController : ManageHttpController {
    private ManagePrintClientsUseCase usecase;

    this(ManagePrintClientsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/print/clients", &handleList);
        router.get("/api/v1/print/clients/*", &handleGet);
        router.post("/api/v1/print/clients", &handleCreate);
        router.put("/api/v1/print/clients/*", &handleUpdate);
        router.delete_("/api/v1/print/clients/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listPrintClients(tenantId);
            auto list = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", list);
            return successResponse("Print client list retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = PrintClientId(precheck.id);
            if (id.isNull)
                return errorResponse("Invalid print client ID", 400);

            auto e = usecase.getPrintClient(tenantId, id);
            if (e.isNull)
                return errorResponse("Print client not found", 404);

            return successResponse("Print client retrieved successfully", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            PrintClientDTO dto;
            dto.clientId = PrintClientId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.version_ = data.getString("version");
            dto.hostName = data.getString("hostName");
            dto.ipAddress = data.getString("ipAddress");
            dto.osType = data.getString("osType");
            dto.osVersion = data.getString("osVersion");

            auto result = usecase.registerPrintClient(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id);
            return successResponse("Print client registered successfully", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto data = precheck.data;
            PrintClientDTO dto;
            dto.clientId = PrintClientId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.version_ = data.getString("version");
            dto.ipAddress = data.getString("ipAddress");

            auto result = usecase.updatePrintClient(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id);
            return successResponse("Print client updated successfully", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = PrintClientId(precheck.id);
            auto result = usecase.deletePrintClient(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto resp = Json.emptyObject
                .set("id", result.id);
            return successResponse("Print client deleted successfully", 200, resp);
    }
}
