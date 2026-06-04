/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_queue;

import uim.platform.print;

mixin(ShowModule!());

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
                .set("resources", jarr)
                .set("message", "Print queue list retrieved successfully");
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
            auto id = PrintQueueId(precheck.id);
            auto e = usecase.getPrintQueue(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Print queue not found"); return; }
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
            PrintQueueDTO dto;
            dto.queueId = PrintQueueId(precheck.id);
            dto.tenantId = precheck.tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.printerId = data.getString("printerId");
            dto.location = data.getString("location");
            dto.costCenter = data.getString("costCenter");
            dto.isDefault = data.getBoolean("isDefault");
            dto.maxRetries = cast(int) j.getInt("maxRetries");
            dto.retentionDays = cast(int) j.getInt("retentionDays");

            auto result = usecase.createPrintQueue(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Print queue created successfully");
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
            auto data = precheck.data;
            PrintQueueDTO dto;
            dto.queueId = PrintQueueId(precheck.id);
            dto.tenantId = precheck.tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.location = data.getString("location");
            dto.costCenter = data.getString("costCenter");
            dto.status = data.getString("status");

            auto result = usecase.updatePrintQueue(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Print queue updated successfully");
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
            auto id = PrintQueueId(precheck.id);
            auto result = usecase.deletePrintQueue(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Print queue deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
