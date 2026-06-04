/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.printer;

import uim.platform.print;

mixin(ShowModule!());

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
                .set("resources", jarr)
                .set("message", "Printer list retrieved successfully");
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
            auto id = PrinterId(precheck.id);
            auto e = usecase.getPrinter(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Printer not found"); return; }
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
            PrinterDTO dto;
            dto.printerId = PrinterId(precheck.id);
            dto.tenantId = precheck.tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.host = data.getString("host");
            auto portVal = cast(int) j.getInt("port");
            dto.port = portVal > 0 ? cast(ushort) portVal : 631;
            dto.queue = data.getString("queue");
            dto.location = data.getString("location");
            dto.model = data.getString("model");
            dto.vendor = data.getString("vendor");
            dto.protocol = data.getString("protocol");
            dto.colorCapable = data.getBoolean("colorCapable");
            dto.duplexCapable = data.getBoolean("duplexCapable");
            dto.clientId = data.getString("clientId");

            auto result = usecase.createPrinter(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Printer registered successfully");
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
            PrinterDTO dto;
            dto.printerId = PrinterId(precheck.id);
            dto.tenantId = precheck.tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.host = data.getString("host");
            dto.location = data.getString("location");
            dto.status = data.getString("status");

            auto result = usecase.updatePrinter(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Printer updated successfully");
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
            auto id = PrinterId(precheck.id);
            auto result = usecase.deletePrinter(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Printer deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
