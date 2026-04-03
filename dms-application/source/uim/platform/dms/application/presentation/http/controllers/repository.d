module uim.platform.dms_application.presentation.http.controllers.repository;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import uim.platform.dms_application.application.usecases.manage_repositories;
// import uim.platform.dms_application.application.dto;
// import uim.platform.dms_application.domain.entities.repository;
// import uim.platform.dms_application.domain.types;
// import uim.platform.dms_application.presentation.http.json_utils;

import uim.platform.dms_application;
mixin(ShowModule!());
@safe:

class RepositoryController : SAPController {
  private ManageRepositoriesUseCase uc;

  this(ManageRepositoriesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/repositories", &handleCreate);
    router.get("/api/v1/repositories", &handleList);
    router.get("/api/v1/repositories/*", &handleGetById);
    router.put("/api/v1/repositories/*", &handleUpdate);
    router.delete_("/api/v1/repositories/*", &handleDelete);
    router.post("/api/v1/repositories/activate/*", &handleActivate);
    router.post("/api/v1/repositories/archive/*", &handleArchive);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateRepositoryRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.maxFileSize = jsonLong(j, "maxFileSize");
      r.allowedFileTypes = j.getString("allowedFileTypes");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createRepository(r);
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
      auto items = uc.listRepositories(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; items)
        arr ~= serializeRepo(r);

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
      auto repo = uc.getRepository(id, tenantId);
      if (repo is null) {
        writeError(res, 404, "Repository not found");
        return;
      }
      res.writeJsonBody(serializeRepo(repo), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateRepositoryRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.maxFileSize = jsonLong(j, "maxFileSize");
      r.allowedFileTypes = j.getString("allowedFileTypes");

      auto result = uc.updateRepository(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Repository not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.activateRepository(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("active");
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.archiveRepository(id, tenantId);
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
      auto result = uc.deleteRepository(id, tenantId);
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

  private static Json serializeRepo(const Repository r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["status"] = Json(r.status.to!string);
    j["maxFileSize"] = Json(r.maxFileSize);
    j["allowedFileTypes"] = Json(r.allowedFileTypes);
    j["createdBy"] = Json(r.createdBy);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);
    return j;
  }
}
