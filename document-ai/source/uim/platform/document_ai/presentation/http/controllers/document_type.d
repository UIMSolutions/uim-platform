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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateDocumentTypeRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");
      r.supportedFileTypes = getStrings(j, "supportedFileTypes");

      auto result = usecase.createDocumentType(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Document type created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto types = usecase.listDocumentTypes(clientId);
      auto jarr = types.map!(dt => dt.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("count", Json(types.length))
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentTypeprecheck.id);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto dt = usecase.getDocumentType(tenantId, id, clientId);
      if (dt.isNull) {
        writeError(res, 404, "Document type not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", dt.id)
        .set("name", dt.name)
        .set("description", dt.description)
        .set("category", dt.category)
        .set("defaultSchemaId", dt.defaultSchemaId)
        .set("supportedFileTypes", dt.supportedFileTypes)
        .set("createdAt", dt.createdAt)
        .set("updatedAt", dt.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentTypeprecheck.id);
      auto j = req.json;

      UpdateDocumentTypeRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.documentTypeId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.defaultSchemaId = j.getString("defaultSchemaId");

      auto result = usecase.updateDocumentType(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Document type updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentTypeprecheck.id);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteDocumentType(tenantId, id, clientId);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
