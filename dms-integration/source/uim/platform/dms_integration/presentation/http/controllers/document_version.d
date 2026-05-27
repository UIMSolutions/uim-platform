/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.document_version;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class DocumentVersionController : ManageController {
    private ManageDocumentVersionsUseCase usecase;

    this(ManageDocumentVersionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/document-versions", &handleList);
        router.get("/api/v1/dms-integration/document-versions/*", &handleGet);
        router.post("/api/v1/dms-integration/document-versions", &handleCreate);
        router.delete_("/api/v1/dms-integration/document-versions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        DocumentVersion[] items;
        auto documentId = req.query.get("documentId", "");
        auto filter = req.query.get("filter", "");
        if (documentId.length > 0) {
            if (filter == "major") {
                items = usecase.listMajorVersions(tenantId, DocumentId(documentId));
            } else if (filter == "latest") {
                items = usecase.listLatestVersions(tenantId, DocumentId(documentId));
            } else {
                items = usecase.listVersionsByDocument(tenantId, DocumentId(documentId));
            }
        }
        auto jarr = items.map!(e => e.toJson).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Document version list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        DocumentVersionDTO dto;
        dto.tenantId = tenantId;
        dto.documentId = DocumentId(j.getString("documentId"));
        dto.repositoryId = RepositoryId(j.getString("repositoryId"));
        dto.versionLabel = j.getString("versionLabel");
        dto.isMajorVersion = j.getBool("isMajorVersion");
        dto.comment = j.getString("comment");
        dto.fileSizeBytes = j.getLong("fileSizeBytes");
        dto.mimeType = j.getString("mimeType");
        dto.fileName = j.getString("fileName");
        dto.checksum = j.getString("checksum");
        dto.contentStreamId = j.getString("contentStreamId");
        dto.checkinComment = j.getString("checkinComment");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = usecase.createDocumentVersion(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Document version created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DocumentVersionId(precheck.id);
        if (id.isNull) {
            return errorResponse("Invalid document version ID", 400);
        }

        auto item = usecase.getDocumentVersion(tenantId, id);
        if (item.isNull)
            return errorResponse("Document version not found", 404);

        auto responseData = item.toJson();
        return successResponse("Document version retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DocumentVersionId(precheck.id);
        if (id.isNull) {
            return errorResponse("Invalid document version ID", 400);
        }
        auto result = usecase.deleteDocumentVersion(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Document version deleted successfully", "Deleted", 200, responseData);
    }
}
