/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.document;
// import uim.platform.document_ai.application.usecases.process_documents;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.document : Document;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class DocumentController : HttpController {
  private ProcessDocumentsUseCase usecase;

  this(ProcessDocumentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/document/jobs", &handleUpload);
    router.get("/api/v1/document/jobs", &handleList);
    router.get("/api/v1/document/jobs/*", &handleGet);
    router.delete_("/api/v1/document/jobs/*", &handleDelete);
    router.post("/api/v1/document/jobs/confirm/*", &handleConfirm);
    router.get("/api/v1/document/jobs/results/*", &handleResult);
  }

  protected Json uploadHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    CreateDocumentRequest r;
    r.tenantId = precheck.tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.fileName = data.getString("fileName");
    r.mimeType = data.getString("mimeType");
    r.fileSize = data.getLong("fileSize");
    r.schemaId = data.getString("schemaId");
    r.templateId = data.getString("templateId");
    r.documentTypeId = data.getString("documentTypeId");
    r.language = data.getString("language");
    r.labels = jsonKeyValuePairs(data, "labels");

    auto result = usecase.upload(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", Json("pending"))
      .set("message", "Document uploaded for processing");

    return successResponse("Document uploaded successfully", 201, resp);
  }

  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = uploadHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
    auto docs = usecase.list(tenantId, clientId);

    auto list = docs.map!(d => toJson(d)).array.toJson;
    auto resp = Json.emptyObject
      .set("count", Json(docs.length))
      .set("resources", list);

    return successResponse("Documents retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto d = usecase.getById(tenantId, id, clientId);
    if (d.isNull)
      return errorResponse("Document not found", 404);

    return successResponse("Document retrieved successfully", 200, toJson(d));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.deleteDocument(tenantId, id, clientId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Document deleted successfully", 200, responseData);
  }

  protected Json confirmHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto data = precheck.data;
    ConfirmDocumentRequest r;
    r.tenantId = precheck.tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.documentId = id;
    r.correctedFields = jsonKeyValuePairs(data, "correctedFields");

    auto result = usecase.confirm(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id);
    return successResponse("Document confirmed successfully", 200, responseData);
  }

  protected void handleConfirm(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = confirmHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json resultHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DocumentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid document ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.getExtractionResult(tenantId, id, clientId);
    if (result.isNull)
      return errorResponse("Extraction result not found", 404);


    auto rj = Json.emptyObject
      .set("id", result.id)
      .set("documentId", result.documentId)
      .set("schemaId", result.schemaId)
      .set("method", result.method.to!string)
      .set("overallConfidence", result.overallConfidence)
      .set("extractedFieldCount", result.extractedFieldCount)
      .set("totalPages", result.totalPages)
      .set("processedAt", result.processedAt);

    auto hArr = Json.emptyArray;
    foreach (f; result.headerFields) {
      hArr ~= Json.emptyObject
        .set("name", f.name)
        .set("value", f.value)
        .set("type", f.type.to!string)
        .set("confidence", f.confidence)
        .set("page", f.page);
    }
    rj["headerFields"] = hArr;

    auto liArr = Json.emptyArray;
    foreach (li; result.lineItems) {
      auto lij = Json.emptyObject;
      lij["rowIndex"] = Json(li.rowIndex);
      auto liFields = Json.emptyArray;
      foreach (f; li.fields) {
        liFields ~= Json.emptyObject
          .set("name", f.name)
          .set("value", f.value)
          .set("type", f.type.to!string)
          .set("confidence", f.confidence);
      }
      lij["fields"] = liFields;
      liArr ~= lij;
    }
    rj["lineItems"] = liArr;
    return successResponse("Extraction result retrieved successfully", 200, rj);
  }

  protected void handleResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = resultHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}