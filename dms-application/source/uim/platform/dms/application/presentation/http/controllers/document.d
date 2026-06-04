/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.document;

// 
// 
// import uim.platform.dms.application.application.usecases.manage.documents;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class DocumentController : ManageHttpController {
  private ManageDocumentsUseCase usecase;

  this(ManageDocumentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/documents", &handleCreate);
    router.get("/api/v1/documents", &handleList);
    router.get("/api/v1/documents/search", &handleSearch);
    router.get("/api/v1/documents/*", &handleGet);
    router.put("/api/v1/documents/*", &handleUpdate);
    router.delete_("/api/v1/documents/*", &handleDelete);
    router.post("/api/v1/documents/move/*", &handleMove);
    router.post("/api/v1/documents/archive/*", &handleArchive);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateDocumentRequest();
    r.tenantId = precheck.tenantId;
    r.repositoryId = data.getString("repositoryId");
    r.folderId = data.getString("folderId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.contentCategory = data.getString("contentCategory").to!ContentCategory;
    r.mimeType = data.getString("mimeType");
    r.fileSize = data.getLong("fileSize");
    r.tags = data.getString("tags");
    r.properties = data.getString("properties");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createDocument(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Document created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listDocuments(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Documents retrieved successfully", 200, responseData);
  }

  protected Json searchHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto query = req.headers.get("X-Search-Query", "");
    if (query.length == 0) {
      // Try query param
      auto uri = req.requestURI;
      auto qIdx = uri.indexOf("q=");
      if (qIdx >= 0) {
        auto rest = uri[cast(size_t)(qIdx + 2) .. $];
        auto ampIdx = rest.indexOf('&');
        query = ampIdx >= 0 ? rest[0 .. cast(size_t)ampIdx] : rest;
      }
    }

    auto items = usecase.searchByName(tenantId, query);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("", 0, responseData);
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = searchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto doc = usecase.getDocument(tenantId, id);
    if (doc.isNull)
      return errorResponse("Document not found", 404);

    return successResponse("Document retrieved successfully", 200, doc.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto data = precheck.data;
    auto r = UpdateDocumentRequest();
    r.documentId = id;
    r.tenantId = precheck.tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.tags = data.getString("tags");
    r.properties = data.getString("properties");

    auto result = usecase.updateDocument(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Document updated successfully", 200, responseData);
  }

  protected void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);
      auto data = precheck.data;
      auto r = MoveDocumentRequest();
      r.documentId = id;
      r.tenantId = precheck.tenantId;
      r.newFolderId = data.getString("newFolderId");

      auto result = usecase.moveDocument(r);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Document moved successfully", 200, responseData);
    }

    protected void handleArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto tenantId = precheck.tenantId;
        auto id = DocumentId(precheck.id);

        auto result = usecase.archiveDocument(tenantId, id);
        if (result.isSuccess) {
          auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", "archived");

          res.writeJsonBody(resp, 200);
        } else
          writeError(res, 404, result.message);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
      auto precheck = super.deleteHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);

      auto result = usecase.deleteDocument(tenantId, id);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Document deleted successfully", 200, responseData);
  }
}
