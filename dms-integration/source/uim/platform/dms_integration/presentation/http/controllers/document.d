/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.document;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class DocumentController : PlatformController {
    private ManageDocumentsUseCase usecase;

    this(ManageDocumentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/documents", &handleList);
        router.get("/api/v1/dms-integration/documents/*", &handleGet);
        router.post("/api/v1/dms-integration/documents", &handleCreate);
        router.put("/api/v1/dms-integration/documents/*", &handleUpdate);
        router.delete_("/api/v1/dms-integration/documents/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            Document[] items;
            auto search = req.query.get("search", "");
            auto folderId = req.query.get("folderId", "");
            auto status = req.query.get("status", "");
            if (search.length > 0) {
                items = usecase.searchDocumentsByName(tenantId, search);
            } else if (folderId.length > 0) {
                items = usecase.listDocumentsByFolder(tenantId, FolderId(folderId));
            } else if (status == "checkedOut") {
                items = usecase.listCheckedOutDocuments(tenantId);
            } else {
                items = usecase.listDocuments(tenantId);
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
            auto id = DocumentId(extractIdFromPath(path));
            auto item = usecase.getDocument(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Document not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DocumentDTO dto;
            dto.documentId = DocumentId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.repositoryId = RepositoryId(j.getString("repositoryId"));
            dto.folderId = FolderId(j.getString("folderId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.mimeType = j.getString("mimeType");
            dto.fileSizeBytes = j.getLong("fileSizeBytes");
            dto.fileName = j.getString("fileName");
            dto.fileExtension = j.getString("fileExtension");
            dto.language = j.getString("language");
            dto.tags = j.getString("tags");
            dto.externalId = j.getString("externalId");
            dto.sourceSystem = j.getString("sourceSystem");
            dto.externalLink = j.getString("externalLink");
            dto.validFrom = j.getString("validFrom");
            dto.validTo = j.getString("validTo");
            dto.searchContent = j.getString("searchContent");
            dto.customProperties = j.getString("customProperties");
            dto.versionLabel = j.getString("versionLabel");
            dto.isMajorVersion = j.getBool("isMajorVersion");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.createDocument(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document created"), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            auto action = j.getString("action");
            auto id = DocumentId(extractIdFromPath(path));
            auto userId = UserId(j.getString("userId"));

            if (action == "checkout") {
                auto result = usecase.checkoutDocument(tenantId, id, userId);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document checked out"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "checkin") {
                auto isMajor = j.getBool("isMajorVersion");
                auto comment = j.getString("comment");
                auto result = usecase.checkinDocument(tenantId, id, userId, isMajor, comment);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document checked in"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "cancelCheckout") {
                auto result = usecase.cancelCheckout(tenantId, id, userId);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Checkout cancelled"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "move") {
                auto targetFolderId = FolderId(j.getString("targetFolderId"));
                auto result = usecase.moveDocument(tenantId, id, targetFolderId, userId);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document moved"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "publish") {
                auto result = usecase.publishDocument(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document published"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "archive") {
                auto result = usecase.archiveDocument(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document archived"), 200);
                else writeError(res, 400, result.message);
                return;
            }

            DocumentDTO dto;
            dto.documentId = id;
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.tags = j.getString("tags");
            dto.language = j.getString("language");
            dto.validFrom = j.getString("validFrom");
            dto.validTo = j.getString("validTo");
            dto.customProperties = j.getString("customProperties");
            dto.updatedBy = userId;
            auto result = usecase.updateDocument(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document updated"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DocumentId(extractIdFromPath(path));
            auto result = usecase.deleteDocument(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Document deleted"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
