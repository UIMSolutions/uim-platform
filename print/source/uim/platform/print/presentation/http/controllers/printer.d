/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.printer;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class PrinterController : ManageHttpController {
    private ManagePrintersUseCase usecase;

    this(ManagePrintersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/print/printers", &handleList);
        router.get("/api/v1/print/printers/*", &handleGet);
        router.post("/api/v1/print/printers", &handleCreate);
        router.put("/api/v1/print/printers/*", &handleUpdate);
        router.delete_("/api/v1/print/printers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listPrinters(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Printers retrieved successfully", "Retrieved", 200, resp);
    }

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = PrinterId(precheck.id);
    auto e = usecase.getPrinter(tenantId, id);
    if (e.isNull) 
        return errorResponse("Printer not found", 404);

    auto resp = Json.emptyObject
        .set("id", e.printerId)
        .set("name", e.name)
        .set("description", e.description)
        .set("host", e.host)
        .set("port", e.port)
        .set("queue", e.queue)
        .set("location", e.location)
        .set("model", e.model)
        .set("vendor", e.vendor)
        .set("protocol", e.protocol)
        .set("colorCapable", e.colorCapable)
        .set("duplexCapable", e.duplexCapable)
        .set("clientId", e.clientId);   

    return successResponse("Printer retrieved successfully", "Retrieved", 200, resp);
}

override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    PrinterDTO dto;
    dto.printerId = PrinterId(precheck.id);
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.host = data.getString("host");
    auto portVal = cast(int)j.getInt("port");
    dto.port = portVal > 0 ? cast(ushort)portVal : 631;
    dto.queue = data.getString("queue");
    dto.location = data.getString("location");
    dto.model = data.getString("model");
    dto.vendor = data.getString("vendor");
    dto.protocol = data.getString("protocol");
    dto.colorCapable = data.getBoolean("colorCapable");
    dto.duplexCapable = data.getBoolean("duplexCapable");
    dto.clientId = data.getString("clientId");

    auto result = usecase.createPrinter(dto);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id);
    return successResponse("Printer created successfully", "Created", 201, resp);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    PrinterDTO dto;
    dto.printerId = PrinterId(precheck.id);
    dto.tenantId = tenantId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.host = data.getString("host");
    dto.location = data.getString("location");
    dto.status = data.getString("status");

    auto result = usecase.updatePrinter(dto);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id);
    return successResponse("Printer updated successfully", "Updated", 200, resp);
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PrinterId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid printer ID", 400);

    auto result = usecase.deletePrinter(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id);
    return successResponse("Printer deleted successfully", "Deleted", 200, resp);
}
}
