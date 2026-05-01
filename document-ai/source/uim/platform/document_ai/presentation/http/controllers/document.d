/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.document;

import uim.platform.document_ai.application.usecases.process_documents;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document : Document;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class DocumentController : PlatformController {
  private ProcessDocumentsUseCase uc;

  this(ProcessDocumentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/document/jobs", &handleUpload);
    router.get("/api/v1/document/jobs", &handleList);
    router.get("/api/v1/document/jobs/*", &handleGet);
    router.delete_("/api/v1/document/jobs/*", &handleDelete);
    router.post("/api/v1/document/jobs/confirm/*", &handleConfirm);
    router.get("/api/v1/document/jobs/results/*", &handleGetResult);
  }

  private void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UploadDocumentRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.fileName = j.getString("fileName");
      r.mimeType = j.getString("mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.schemaId = j.getString("schemaId");
      r.templateId = j.getString("templateId");
      r.documentTypeId = j.getString("documentTypeId");
      r.language = j.getString("language");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.upload(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("status", Json("pending"))
          .set("message", Json("Document uploaded for processing"));

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto clientId = req.headers.get("X-Client-Id", "");
      auto docs = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (d; docs) {
        jarr ~= documentToJson(d);
      }

      auto resp = Json.emptyObject
        .set("count", Json(docs.length))
        .set("resources", jarr)
        .set("message", Json("Document list retrieved successfully"));
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto d = uc.getById(id, clientId);
      if (d.isNull) {
        writeError(res, 404, "Document not found");
        return;
      }

      res.writeJsonBody(documentToJson(d), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto result = uc.remove(id, clientId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleConfirm(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      ConfirmDocumentRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentId = id;
      r.correctedFields = jsonKeyValuePairs(j, "correctedFields");

      auto result = uc.confirm(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "confirmed")
          .set("message", "Document confirmed for feedback");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto docId = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto result = uc.getExtractionResult(docId, clientId);
      if (result.isNull) {
        writeError(res, 404, "Extraction result not found");
        return;
      }

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

      res.writeJsonBody(rj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json documentToJson(Document d) {
    import std.conv : to;

    auto dj = Json.emptyObject
      .set("id", d.id)
      .set("fileName", d.fileName)
      .set("fileType", d.fileType.to!string)
      .set("category", d.category.to!string)
      .set("documentTypeId", d.documentTypeId)
      .set("status", d.status.to!string)
      .set("language", d.language)
      .set("fileSize", d.fileSize)
      .set("mimeType", d.mimeType)
      .set("schemaId", d.schemaId)
      .set("templateId", d.templateId)
      .set("extractionMethod", d.extractionMethod.to!string)
      .set("uploadedAt", d.uploadedAt)
      .set("processedAt", d.processedAt)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);

    auto lArr = Json.emptyArray;
    foreach (lbl; d.labels) {
      lArr ~= Json.emptyObject
        .set("key", lbl.key)
        .set("value", lbl.value);
    }
    dj["labels"] = lArr;

    return dj;
  }
}
