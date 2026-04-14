/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.directory;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class DirectoryController : PlatformController {
  private ManageDirectoriesUseCase uc;

  this(ManageDirectoriesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/directories", &handleCreate);
    router.get("/api/v1/directories", &handleList);
    router.get("/api/v1/directories/*", &handleGet);
    router.put("/api/v1/directories/*", &handleUpdate);
    router.delete_("/api/v1/directories/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDirectoryRequest r;
      r.globalAccountId = j.getString("globalAccountId");
      r.parentDirectoryId = j.getString("parentDirectoryId");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.features = getStringArray(j, "features");
      r.manageEntitlements = j.getBoolean("manageEntitlements");
      r.manageAuthorizations = j.getBoolean("manageAuthorizations");
      r.createdBy = req.headers.get("X-User-Id", "");
      r.labels = jsonStrMap(j, "labels");
      r.customProperties = jsonStrMap(j, "customProperties");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto gaId = req.params.get("globalAccountId");
      auto parentId = req.params.get("parentDirectoryId");

      Directory[] items;
      if (parentId.length > 0)
        items = uc.listByParent(parentId);
      else if (gaId.length > 0)
        items = uc.listByGlobalAccount(gaId);

      auto arr = items.map!(d => serializeDirectory(d)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto d = uc.getById(id);
      if (d.id.isEmpty) {
        writeError(res, 404, "Directory not found");
        return;
      }
      res.writeJsonBody(serializeDirectory(d), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateDirectoryRequest request;
      request.displayName = j.getString("displayName");
      request.description = j.getString("description");
      request.labels = jsonStrMap(j, "labels");
      request.customProperties = jsonStrMap(j, "customProperties");

      auto result = uc.update(id, request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = uc.remove(extractId(req.requestURI));
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeDirectory(Directory directory) {
  return Json.emptyObject
    .set("id", directory.id)
    .set("globalAccountId", directory.globalAccountId)
    .set("parentDirectoryId", directory.parentDirectoryId)
    .set("displayName", directory.displayName)
    .set("description", directory.description)
    .set("status", to!string(directory.status))
    .set("manageEntitlements", directory.manageEntitlements)
    .set("manageAuthorizations", directory.manageAuthorizations)
    .set("createdBy", directory.createdBy)
    .set("createdAt", directory.createdAt)
    .set("modifiedAt", directory.modifiedAt)
    .set("labels", directory.labels)
    .set("customProperties", directory.customProperties.toJson)
    .set("subaccounts", directory.subaccounts.toJson)
    .set("subdirectories", directory.subdirectories.toJson);
}
