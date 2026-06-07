/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.document;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class DocumentController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Document list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        DocumentDTO dto;
        dto.documentId = DocumentId(precheck.id);
        dto.tenantId = tenantId;
        dto.repositoryId = RepositoryId(data.getString("repositoryId"));
        dto.folderId = FolderId(data.getString("folderId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.mimeType = data.getString("mimeType");
        dto.fileSizeBytes = data.getLong("fileSizeBytes");
        dto.fileName = data.getString("fileName");
        dto.fileExtension = data.getString("fileExtension");
        dto.language = data.getString("language");
        dto.tags = data.getString("tags");
        dto.externalId = data.getString("externalId");
        dto.sourceSystem = data.getString("sourceSystem");
        dto.externalLink = data.getString("externalLink");
        dto.validFrom = data.getString("validFrom");
        dto.validTo = data.getString("validTo");
        dto.searchContent = data.getString("searchContent");
        dto.customProperties = data.getString("customProperties");
        dto.versionLabel = data.getString("versionLabel");
        dto.isMajorVersion = data.getBoolean("isMajorVersion");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDocument(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Document created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DocumentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid document ID", 400);

        auto item = usecase.getDocument(tenantId, id);
        if (item.isNull)
            return errorResponse("Document not found", 404);

        auto responseData = item.toJson();
        return successResponse("Document retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DocumentId(precheck.id);
        auto data = precheck.data;
        auto userId = UserId(data.getString("userId"));

        auto action = data.getString("action");
        switch (action) {
        case "checkout":
            auto result = usecase.checkoutDocument(tenantId, id, userId);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document checked out successfully", "CheckedOut", 200, responseData);
            // TODO: Revisit force checkout action - may not be needed if we have proper checkout cancellation and admin override mechanisms in place   
            // case "forceCheckout":
            //     auto result = usecase.forceCheckoutDocument(tenantId, id, userId);
            //     if (result.hasError)
            //         return errorResponse(result.message, 400);

            //     auto responseData = Json.emptyObject.set("id", result.id);
            //     return successResponse("Document force checked out successfully", "ForceCheckedOut", 200, responseData);
        case "checkin":
            auto isMajor = data.getBoolean("isMajorVersion");
            auto comment = data.getString("comment");
            auto result = usecase.checkinDocument(tenantId, id, userId, isMajor, comment);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document checked in successfully", "CheckedIn", 200, responseData);
        case "cancelCheckout":
            auto result = usecase.cancelCheckout(tenantId, id, userId);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document checkout cancelled successfully", "CheckoutCancelled", 200, responseData);
        case "move":
            auto targetFolderId = FolderId(data.getString("targetFolderId"));
            auto result = usecase.moveDocument(tenantId, id, targetFolderId, userId);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document moved successfully", "Moved", 200, responseData);
        case "publish":
            auto result = usecase.publishDocument(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document published successfully", "Published", 200, responseData);
        case "archive":
            auto result = usecase.archiveDocument(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Document archived successfully", "Archived", 200, responseData);
        case "updateMetadata":
            break; // TODO: Implement update metadata action    
        case "updateContent":
            break; // TODO: Implement update content action
        default:
            // TODO: Implement other actions as needed (e.g. tag management, permission management, etc.)
            break;
        }

        DocumentDTO dto;
        dto.documentId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.tags = data.getString("tags");
        dto.language = data.getString("language");
        dto.validFrom = data.getString("validFrom");
        dto.validTo = data.getString("validTo");
        dto.customProperties = data.getString("customProperties");
        dto.updatedBy = userId;
        auto result = usecase.updateDocument(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Document updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DocumentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid document ID", 400);

        auto result = usecase.deleteDocument(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Document deleted successfully", "Deleted", 200, responseData);
    }
}
