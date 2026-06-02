/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.document_type;
// import uim.platform.document_ai.application.usecases.manage.document_types;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.document_type : DocumentType;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class DocumentTypeController : ManageController {
  private ManageDocumentTypesUseCase usecase;

  this(ManageDocumentTypesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/document-types", &handleCreate);
    router.get("/api/v1/document-types", &handleList);
    router.get("/api/v1/document-types/*", &handleGet);
    router.put("/api/v1/document-types/*", &handleUpdate);
    router.delete_("/api/v1/document-types/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateDocumentTypeRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.defaultSchemaId = data.getString("defaultSchemaId");
    r.supportedFileTypes = data.getStrings("supportedFileTypes");

    auto result = usecase.createDocumentType(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Document type created");

    return successResponse("Document type created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto types = usecase.listDocumentTypes(tenantId, clientId);
    auto list = types.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Document types retrieved successfully", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentTypeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document type ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto dt = usecase.getDocumentType(tenantId, id, clientId);
    if (dt.isNull)
      return errorResponse("Document type not found", 404);

    auto responseData = Json.emptyObject
      .set("id", dt.id)
      .set("name", dt.name)
      .set("description", dt.description)
      .set("category", dt.category)
      .set("defaultSchemaId", dt.defaultSchemaId)
      .set("supportedFileTypes", dt.supportedFileTypes)
      .set("createdAt", dt.createdAt)
      .set("updatedAt", dt.updatedAt);

    return successResponse("Document type retrieved successfully", 0, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentTypeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document type ID", 400);

    auto data = precheck.data;
    UpdateDocumentTypeRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.documentTypeId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.defaultSchemaId = data.getString("defaultSchemaId");

    auto result = usecase.updateDocumentType(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Document type updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentTypeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document type ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.deleteDocumentType(tenantId, id, clientId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Document type deleted successfully", 204, Json.emptyObject);
  }
}
