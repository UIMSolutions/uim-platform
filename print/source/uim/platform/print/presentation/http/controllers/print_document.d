/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_document;

import uim.platform.print;

mixin(ShowModule!());

@safe:

class PrintDocumentController : ManageController {
    private ManagePrintDocumentsUseCase usecase;

    this(ManagePrintDocumentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/print/documents", &handleList);
        router.get("/api/v1/print/documents/*", &handleGet);
        router.post("/api/v1/print/documents", &handleCreate);
        router.delete_("/api/v1/print/documents/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listPrintDocuments(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Document list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = PrintDocumentId(precheck.id);
            auto e = usecase.getPrintDocument(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Document not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            PrintDocumentDTO dto;
            dto.documentId = PrintDocumentId(precheck.id);
            dto.tenantId = tenantId;
            dto.fileName = j.getString("fileName");
            dto.mimeType = j.getString("mimeType");
            dto.format = j.getString("format");
            dto.sizeBytes = j.getInt("sizeBytes");
            dto.storageUri = j.getString("storageUri");
            dto.checksum = j.getString("checksum");
            dto.description = j.getString("description");
            dto.expiresAt = j.getInt("expiresAt");

            auto result = usecase.createPrintDocument(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Document registered successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeError(res, 405, "Method not allowed — use POST to upload a new document");
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = PrintDocumentId(precheck.id);
            auto result = usecase.deletePrintDocument(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Document deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
