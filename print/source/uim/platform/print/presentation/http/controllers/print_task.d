/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_task;

import uim.platform.print;
mixin(ShowModule!());

@safe:

class PrintTaskController : ManageHttpController {
    private ManagePrintTasksUseCase usecase;

    this(ManagePrintTasksUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/print/tasks", &handleList);
        router.get("/api/v1/print/tasks/*", &handleGet);
        router.post("/api/v1/print/tasks", &handleCreate);
        router.put("/api/v1/print/tasks/*", &handleUpdate);
        router.delete_("/api/v1/print/tasks/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listPrintTasks(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);
        
        return successResponse("Print task list retrieved successfully", "Retrieved", 200, resp);
}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = PrintTaskId(precheck.id);
    auto e = usecase.getPrintTask(tenantId, id);
    if (e.isNull)
        return errorResponse("Print task not found", 404, Json.emptyObject.set("error", "Print task not found"));
    return successResponse("Print task retrieved successfully", 200, e.toJson());

}

override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    PrintTaskDTO dto;
    dto.taskId = PrintTaskId(precheck.id);
    dto.tenantId = tenantId;
    dto.queueId = data.getString("queueId");
    dto.documentId = data.getString("documentId");
    dto.applicationId = data.getString("applicationId");
    dto.senderApplication = data.getString("senderApplication");
    dto.copies = cast(int)j.getInt("copies");
    if (dto.copies < 1)
        dto.copies = 1;
    dto.paperFormat = data.getString("paperFormat");
    dto.colorPrint = data.getBoolean("colorPrint");
    dto.duplexPrint = data.getBoolean("duplexPrint");
    dto.tray = data.getString("tray");

    auto result = usecase.createPrintTask(dto);
    if (result.hasError) 
        return errorResponse(result.message, 400);
    

    auto resp = Json.emptyObject
        .set("id", result.id);

    return successResponse("Print task created successfully", 201, resp);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = PrintTaskId(precheck.id);
    auto data = precheck.data;
    auto status = data.getString("status");
    auto errorMessage = data.getString("errorMessage");

    auto result = usecase.updatePrintTask(tenantId, id, status, errorMessage);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id);

    return successResponse("Print task updated successfully", 200, resp);
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PrintTaskId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid print task ID", 400);

    auto result = usecase.deletePrintTask(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id);
    return successResponse("Print task deleted successfully", 200, resp);
}
}
