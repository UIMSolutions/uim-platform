/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.document_version;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class DocumentVersionController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            auto resp = Json.emptyObject.set("count", items.length).set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DocumentVersionId(extractIdFromPath(path));
            auto item = usecase.getDocumentVersion(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Document version not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DocumentVersionDTO dto;
            dto.documentVersionId = DocumentVersionId(j.getString("id"));
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
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document version created"), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DocumentVersionId(extractIdFromPath(path));
            auto result = usecase.deleteDocumentVersion(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document version deleted"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
