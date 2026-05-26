/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_task;

import uim.platform.print;

mixin(ShowModule!());

@safe:

class PrintTaskController : ManageController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listPrintTasks(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Print task list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = PrintTaskId(precheck.id);
            auto e = usecase.getPrintTask(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Print task not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            PrintTaskDTO dto;
            dto.taskId = PrintTaskId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.queueId = j.getString("queueId");
            dto.documentId = j.getString("documentId");
            dto.applicationId = j.getString("applicationId");
            dto.senderApplication = j.getString("senderApplication");
            dto.copies = cast(int) j.getInt("copies");
            if (dto.copies < 1) dto.copies = 1;
            dto.paperFormat = j.getString("paperFormat");
            dto.colorPrint = j.getBool("colorPrint");
            dto.duplexPrint = j.getBool("duplexPrint");
            dto.tray = j.getString("tray");

            auto result = usecase.createPrintTask(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Print task created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = PrintTaskId(precheck.id);
            auto j = req.json;
            auto status = j.getString("status");
            auto errorMessage = j.getString("errorMessage");

            auto result = usecase.updatePrintTask(tenantId, id, status, errorMessage);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Print task updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = PrintTaskId(precheck.id);
            auto result = usecase.deletePrintTask(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Print task deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
