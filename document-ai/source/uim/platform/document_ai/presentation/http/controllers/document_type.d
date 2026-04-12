/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.document_type;

import uim.platform.document_ai.application.usecases.manage.document_types;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document_type : DocumentType;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class DocumentTypeController : PlatformController {
  private ManageDocumentTypesUseCase uc;

  this(ManageDocumentTypesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/document-types", &handleCreate);
    router.get("/api/v1/document-types", &handleList);
    router.get("/api/v1/document-types/*", &handleGet);
    router.put("/api/v1/document-types/*", &handleUpdate);
    router.delete_("/api/v1/document-types/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDocumentTypeRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");
      r.supportedFileTypes = jsonStrArray(j, "supportedFileTypes");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Document type created");
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
      auto types = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (dt; types) {
        jarr ~= docTypeToJson(dt);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(types.length);
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

      auto dt = uc.get_(id, clientId);
      if (dt.id.isEmpty) {
        writeError(res, 404, "Document type not found");
        return;
      }

      res.writeJsonBody(docTypeToJson(dt), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateDocumentTypeRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Document type updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
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

  private Json docTypeToJson(DocumentType dt) {
    return Json.emptyObject
      .set("id", dt.id)
      .set("name", dt.name)
      .set("description", dt.description)
      .set("category", dt.category.to!string)
      .set("defaultSchemaId", dt.defaultSchemaId)
      .set("supportedFileTypes", toJsonArray(dt.supportedFileTypes))
      .set("createdAt", dt.createdAt)
      .set("modifiedAt", dt.modifiedAt);
  }
}
