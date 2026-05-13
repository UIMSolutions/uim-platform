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

import uim.platform.document_ai;

class DocumentTypeController : PlatformController {
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

  protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDocumentTypeRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");
      r.supportedFileTypes = getStrings(j, "supportedFileTypes");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Document type created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
      auto types = usecase.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (dt; types) {
        jarr ~= docTypeToJson(dt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(types.length))
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto dt = usecase.getById(id, clientId);
      if (dt.isNull) {
        writeError(res, 404, "Document type not found");
        return;
      }

      res.writeJsonBody(docTypeToJson(dt), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateDocumentTypeRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.documentTypeId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Document type updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteDocumentType(DocumentTypeId(id), clientId);
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
      .set("updatedAt", dt.updatedAt);
  }
}
