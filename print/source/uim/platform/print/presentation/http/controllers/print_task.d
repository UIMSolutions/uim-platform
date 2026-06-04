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
                .set("resources", jarr)
                .set("message", "Print task list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = PrintTaskId(precheck.id);
            auto e = usecase.getPrintTask(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Print task not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            PrintTaskDTO dto;
            dto.taskId = PrintTaskId(precheck.id);
            dto.tenantId = precheck.tenantId;
            dto.queueId = data.getString("queueId");
            dto.documentId = data.getString("documentId");
            dto.applicationId = data.getString("applicationId");
            dto.senderApplication = data.getString("senderApplication");
            dto.copies = cast(int) j.getInt("copies");
            if (dto.copies < 1) dto.copies = 1;
            dto.paperFormat = data.getString("paperFormat");
            dto.colorPrint = data.getBoolean("colorPrint");
            dto.duplexPrint = data.getBoolean("duplexPrint");
            dto.tray = data.getString("tray");

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
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Print task updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = PrintTaskId(precheck.id);
            auto result = usecase.deletePrintTask(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Print task deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
