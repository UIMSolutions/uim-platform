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
class DocumentController : PlatformController {
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

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenanId = req.getTenantId;
      auto j = req.json;
      auto r = CreateDocumentRequest();
      r.tenantId = tenanId;
      r.repositoryId = j.getString("repositoryId");
      r.folderId = j.getString("folderId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.contentCategory = j.getString("contentCategory").to!ContentCategory;
      r.mimeType = j.getString("mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.tags = j.getString("tags");
      r.properties = j.getString("properties");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

  protected void handleGetSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DocumentId(extractIdFromPath(req.requestURI));
      
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

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DocumentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateDocumentRequest();
      r.documentId = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.tags = j.getString("tags");
      r.properties = j.getString("properties");

      auto result = usecase.updateDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Document not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DocumentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = MoveDocumentRequest();
      r.documentId = id;
      r.tenantId = tenantId;
      r.newFolderId = j.getString("newFolderId");

      auto result = usecase.moveDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Document not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DocumentId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.archiveDocument(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "archived");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DocumentId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.deleteDocument(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
