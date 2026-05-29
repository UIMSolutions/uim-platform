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
class DocumentController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenanId = req.getTenantId;
      auto data = precheck.data;
      auto r = CreateDocumentRequest();
      r.tenantId = tenanId;
      r.repositoryId = data.getString("repositoryId");
      r.folderId = data.getString("folderId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.contentCategory = data.getString("contentCategory").to!ContentCategory;
      r.mimeType = data.getString("mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.tags = data.getString("tags");
      r.properties = data.getString("properties");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto items = usecase.listDocuments(tenantId);

      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto query = req.headers.get("X-Search-Query", "");
      if (query.length == 0) {
        // Try query param
        auto uri = req.requestURI;
        // import std.string : indexOf;

        auto qIdx = uri.indexOf("q=");
        if (qIdx >= 0) {
          auto rest = uri[cast(size_t)(qIdx + 2) .. $];
          auto ampIdx = rest.indexOf('&');
          query = ampIdx >= 0 ? rest[0 .. cast(size_t)ampIdx] : rest;
        }
      }

      auto items = usecase.searchByName(tenantId, query);
      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);
      
      auto doc = usecase.getDocument(tenantId, id);
      if (doc.isNull) {
        writeError(res, 404, "Document not found");
        return;
      }
      res.writeJsonBody(doc.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);
      auto data = precheck.data;
      auto r = UpdateDocumentRequest();
      r.documentId = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.tags = data.getString("tags");
      r.properties = data.getString("properties");

      auto result = usecase.updateDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Document not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);
      auto data = precheck.data;
      auto r = MoveDocumentRequest();
      r.documentId = id;
      r.tenantId = tenantId;
      r.newFolderId = data.getString("newFolderId");

      auto result = usecase.moveDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Document not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DocumentId(precheck.id);
      
      auto result = usecase.deleteDocument(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
