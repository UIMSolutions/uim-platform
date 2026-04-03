module uim.platform.dms_application.presentation.http.controllers.document;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import uim.platform.dms_application.application.usecases.manage_documents;
// import uim.platform.dms_application.application.dto;
// import uim.platform.dms_application.domain.entities.document;
// import uim.platform.dms_application.domain.types;
// import uim.platform.dms_application.presentation.http.json_utils;

import uim.platform.dms_application;

mixin(ShowModule!());
@safe:
class DocumentController : SAPController {
  private ManageDocumentsUseCase uc;

  this(ManageDocumentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
       super.registerRoutes(router);

    router.post("/api/v1/documents", &handleCreate);
    router.get("/api/v1/documents", &handleList);
    router.get("/api/v1/documents/search", &handleSearch);
    router.get("/api/v1/documents/*", &handleGetById);
    router.put("/api/v1/documents/*", &handleUpdate);
    router.delete_("/api/v1/documents/*", &handleDelete);
    router.post("/api/v1/documents/move/*", &handleMove);
    router.post("/api/v1/documents/archive/*", &handleArchive);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDocumentRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.repositoryId = j.getString("repositoryId");
      r.folderId = j.getString("folderId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.contentCategory = parseContentCategory(j.getString("contentCategory"));
      r.mimeType = j.getString("mimeType");
      r.fileSize = jsonLong(j, "fileSize");
      r.tags = j.getString("tags");
      r.properties = j.getString("properties");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listDocuments(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; items)
        arr ~= serializeDoc(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto query = req.headers.get("X-Search-Query", "");
      if (query.length == 0) {
        // Try query param
        auto uri = req.requestURI;
        import std.string : indexOf;

        auto qIdx = uri.indexOf("q=");
        if (qIdx >= 0) {
          auto rest = uri[cast(size_t)(qIdx + 2) .. $];
          auto ampIdx = rest.indexOf('&');
          query = ampIdx >= 0 ? rest[0 .. cast(size_t)ampIdx] : rest;
        }
      }

      auto items = uc.searchByName(query, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; items)
        arr ~= serializeDoc(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto doc = uc.getDocument(id, tenantId);
      if (doc is null) {
        writeError(res, 404, "Document not found");
        return;
      }
      res.writeJsonBody(serializeDoc(doc), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateDocumentRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.tags = j.getString("tags");
      r.properties = j.getString("properties");

      auto result = uc.updateDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Document not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MoveDocumentRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.newFolderId = j.getString("newFolderId");

      auto result = uc.moveDocument(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Document not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.archiveDocument(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("archived");
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteDocument(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDoc(const Document d) {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["tenantId"] = Json(d.tenantId);
    j["repositoryId"] = Json(d.repositoryId);
    j["folderId"] = Json(d.folderId);
    j["name"] = Json(d.name);
    j["description"] = Json(d.description);
    j["contentCategory"] = Json(d.contentCategory.to!string);
    j["mimeType"] = Json(d.mimeType);
    j["fileSize"] = Json(d.fileSize);
    j["status"] = Json(d.status.to!string);
    j["currentVersionId"] = Json(d.currentVersionId);
    j["tags"] = Json(d.tags);
    j["properties"] = Json(d.properties);
    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    j["updatedAt"] = Json(d.updatedAt);
    return j;
  }
}
