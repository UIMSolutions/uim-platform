/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.document;

import uim.platform.document_ai.application.use_cases.process_documents;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document : Document;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class DocumentController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.fileName = jsonStr(j, "fileName");
      r.mimeType = jsonStr(j, "mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.schemaId = jsonStr(j, "schemaId");
      r.templateId = jsonStr(j, "templateId");
      r.documentTypeId = jsonStr(j, "documentTypeId");
      r.language = jsonStr(j, "language");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.upload(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("pending");
        resp["message"] = Json("Document uploaded for processing");
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
      foreach (ref d; docs) {
        jarr ~= documentToJson(d);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) docs.length);
      resp["resources"] = jarr;
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

      auto d = uc.get_(id, clientId);
      if (d.id.length == 0) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentId = id;
      r.correctedFields = jsonKeyValuePairs(j, "correctedFields");

      auto result = uc.confirm(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("confirmed");
        resp["message"] = Json("Document confirmed for feedback");
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
      if (result.id.length == 0) {
        writeError(res, 404, "Extraction result not found");
        return;
      }

      auto rj = Json.emptyObject;
      rj["id"] = Json(result.id);
      rj["documentId"] = Json(result.documentId);
      rj["schemaId"] = Json(result.schemaId);
      rj["method"] = Json(result.method.to!string);
      rj["overallConfidence"] = Json(result.overallConfidence);
      rj["extractedFieldCount"] = Json(cast(long) result.extractedFieldCount);
      rj["totalPages"] = Json(cast(long) result.totalPages);
      rj["processedAt"] = Json(result.processedAt);

      auto hArr = Json.emptyArray;
      foreach (ref f; result.headerFields) {
        auto fj = Json.emptyObject;
        fj["name"] = Json(f.name);
        fj["value"] = Json(f.value);
        fj["type"] = Json(f.type.to!string);
        fj["confidence"] = Json(f.confidence);
        fj["page"] = Json(cast(long) f.page);
        hArr ~= fj;
      }
      rj["headerFields"] = hArr;

      auto liArr = Json.emptyArray;
      foreach (ref li; result.lineItems) {
        auto lij = Json.emptyObject;
        lij["rowIndex"] = Json(cast(long) li.rowIndex);
        auto liFields = Json.emptyArray;
        foreach (ref f; li.fields) {
          auto fj = Json.emptyObject;
          fj["name"] = Json(f.name);
          fj["value"] = Json(f.value);
          fj["type"] = Json(f.type.to!string);
          fj["confidence"] = Json(f.confidence);
          liFields ~= fj;
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

  private Json documentToJson(ref Document d) {
    import std.conv : to;

    auto dj = Json.emptyObject;
    dj["id"] = Json(d.id);
    dj["fileName"] = Json(d.fileName);
    dj["fileType"] = Json(d.fileType.to!string);
    dj["category"] = Json(d.category.to!string);
    dj["documentTypeId"] = Json(d.documentTypeId);
    dj["status"] = Json(d.status.to!string);
    dj["language"] = Json(d.language);
    dj["fileSize"] = Json(d.fileSize);
    dj["mimeType"] = Json(d.mimeType);
    dj["schemaId"] = Json(d.schemaId);
    dj["templateId"] = Json(d.templateId);
    dj["extractionMethod"] = Json(d.extractionMethod.to!string);
    dj["uploadedAt"] = Json(d.uploadedAt);
    dj["processedAt"] = Json(d.processedAt);
    dj["createdAt"] = Json(d.createdAt);
    dj["modifiedAt"] = Json(d.modifiedAt);

    auto lArr = Json.emptyArray;
    foreach (ref lbl; d.labels) {
      auto lj = Json.emptyObject;
      lj["key"] = Json(lbl.key);
      lj["value"] = Json(lbl.value);
      lArr ~= lj;
    }
    dj["labels"] = lArr;

    return dj;
  }
}
