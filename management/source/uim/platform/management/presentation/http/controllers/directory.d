/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.directory;


// 
// import uim.platform.management.application.usecases.manage.directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class DirectoryController : ManageController {
  private ManageDirectoriesUseCase usecase;

  this(ManageDirectoriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/directories", &handleCreate);
    router.get("/api/v1/directories", &handleList);
    router.get("/api/v1/directories/*", &handleGet);
    router.put("/api/v1/directories/*", &handleUpdate);
    router.delete_("/api/v1/directories/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDirectoryRequest r;
      r.globalAccountId = j.getString("globalAccountId");
      r.parentDirectoryId = j.getString("parentDirectoryId");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.features = getStrings(j, "features");
      r.manageEntitlements = j.getBoolean("manageEntitlements");
      r.manageAuthorizations = j.getBoolean("manageAuthorizations");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.labels = jsonStrMap(j, "labels");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Directory created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto gaId = req.params.get("globalAccountId");
      auto parentId = req.params.get("parentDirectoryId");

      Directory[] items;
      if (!parentId.isEmpty)
        items = usecase.listDirectories(tenantId, parentId);
      else if (!gaId.isEmpty)
        items = usecase.listDirectories(tenantId, gaId);

      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Directories retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto d = usecase.getById(tenantId, id);
      if (d.isNull) {
        writeError(res, 404, "Directory not found");
        return;
      }
      res.writeJsonBody(d.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateDirectoryRequest request;
      request.displayName = j.getString("displayName");
      request.description = j.getString("description");
      request.labels = jsonStrMap(j, "labels");
      request.customProperties = jsonStrMap(j, "customProperties");

      auto result = usecase.update(tenantId, id, request);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Directory updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DirectoryId(extractId(req.requestURI));

      auto result = usecase.deleteDirectory(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Directory deleted");

        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

