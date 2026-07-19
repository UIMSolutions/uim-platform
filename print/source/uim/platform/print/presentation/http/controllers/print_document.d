/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.presentation.http.controllers.print_document;

import uim.platform.print;
mixin(ShowModule!());

@safe:

class PrintDocumentController : ManageHttpController {
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

        auto items = usecase.listPrintDocuments(tenantId).map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", items);

        return successResponse("Document list retrieved successfully", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PrintDocumentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid document ID", 400);

        auto e = usecase.getPrintDocument(tenantId, id);
        if (e.isNull)
            return errorResponse("Document not found", 404);

        return successResponse("Document retrieved successfully", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PrintDocumentDTO dto;
        dto.documentId = PrintDocumentId(precheck.id);
        dto.tenantId = tenantId;
        dto.fileName = data.getString("fileName");
        dto.mimeType = data.getString("mimeType");
        dto.format = data.getString("format");
        dto.sizeBytes = j.getInt("sizeBytes");
        dto.storageUri = data.getString("storageUri");
        dto.checksum = data.getString("checksum");
        dto.description = data.getString("description");
        dto.expiresAt = j.getInt("expiresAt");

        auto result = usecase.createPrintDocument(dto);
        if (!result.success) {
            writeError(res, 400, result.message);
            return;
        }

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Document created successfully", 201, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = PrintDocumentId(precheck.id);
        auto result = usecase.deletePrintDocument(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Document deleted successfully", 200, resp);
    }
}
