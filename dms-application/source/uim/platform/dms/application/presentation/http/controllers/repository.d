/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.controllers.repository;



// 
// 
// import uim.platform.dms.application.application.usecases.manage.repositories;
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:

class RepositoryController : PlatformController {
  private ManageRepositoriesUseCase usecase;

  this(ManageRepositoriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/repositories", &handleCreate);
    router.get("/api/v1/repositories", &handleList);
    router.get("/api/v1/repositories/*", &handleGet);
    router.put("/api/v1/repositories/*", &handleUpdate);
    router.delete_("/api/v1/repositories/*", &handleDelete);
    router.post("/api/v1/repositories/activate/*", &handleActivate);
    router.post("/api/v1/repositories/archive/*", &handleArchive);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateRepositoryRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.maxFileSize = jsonLong(j, "maxFileSize");
      r.allowedFileTypes = j.getString("allowedFileTypes");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createRepository(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Repository created successfully");

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
      auto items = usecase.listRepositories(tenantId);

      auto arr = items.map!(item => item.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Repositories retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RepositoryId(extractIdFromPath(req.requestURI));

      auto repository = usecase.getRepository(tenantId, id);
      if (repository.isNull) {
        writeError(res, 404, "Repository not found");
        return;
      }
      res.writeJsonBody(repository.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RepositoryId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateRepositoryRequest();
      r.repositoryId = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.maxFileSize = jsonLong(j, "maxFileSize");
      r.allowedFileTypes = j.getString("allowedFileTypes");

      auto result = usecase.updateRepository(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Repository updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Repository not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RepositoryId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.activateRepository(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", Json("active"))
          .set("message", "Repository activated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetArchive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RepositoryId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.archiveRepository(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", Json("archived"));

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RepositoryId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.deleteRepository(tenantId, id);
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
