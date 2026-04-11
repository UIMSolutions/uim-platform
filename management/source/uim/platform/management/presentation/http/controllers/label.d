/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.label;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.labels;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class LabelController : PlatformController {
  private ManageLabelsUseCase uc;

  this(ManageLabelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/labels", &handleCreate);
    router.get("/api/v1/labels", &handleList);
    router.get("/api/v1/labels/*", &handleGet);
    router.put("/api/v1/labels/*", &handleUpdate);
    router.delete_("/api/v1/labels/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateLabelRequest r;
      r.resourceType = j.getString("resourceType");
      r.resourceId = j.getString("resourceId");
      r.key = j.getString("key");
      r.values = jsonStrArray(j, "values");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resourceType = req.params.get("resourceType");
      auto resourceId = req.params.get("resourceId");
      auto key = req.params.get("key");

      Label[] items;
      if (resourceType.length > 0 && resourceId.length > 0)
        items = uc.listByResource(resourceType, resourceId);
      else if (resourceType.length > 0 && key.length > 0)
        items = uc.listByKey(resourceType, key);

      auto arr = Json.emptyArray;
      foreach (l; items)
        arr ~= serializeLabel(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto l = uc.getById(id);
      if (l.id.isEmpty) {
        writeError(res, 404, "Label not found");
        return;
      }
      res.writeJsonBody(serializeLabel(l), 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateLabelRequest r;
      r.values = jsonStrArray(j, "values");

      auto result = uc.update(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeLabel(Label label) {
  return Json.emptyObject
  .set("id", label.id)
  .set("resourceType", to!string(label.resourceType))
  .set("resourceId", label.resourceId)
  .set("key", label.key)
  .set("values", label.values.toJson)
  .set("createdBy", label.createdBy)
  .set("createdAt", label.createdAt)
  .set("modifiedAt", label.modifiedAt);
}
