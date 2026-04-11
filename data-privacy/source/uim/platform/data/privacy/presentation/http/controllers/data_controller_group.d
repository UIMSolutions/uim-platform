/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_controller_group;

// import uim.platform.data.privacy.application.usecases.manage.data_controller_groups;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_controller_group;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DataControllerGroupController : PlatformController {
  private ManageDataControllerGroupsUseCase uc;

  this(ManageDataControllerGroupsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/controller-groups", &handleCreate);
    router.get("/api/v1/controller-groups", &handleList);
    router.get("/api/v1/controller-groups/*", &handleGetById);
    router.put("/api/v1/controller-groups/*", &handleUpdate);
    router.delete_("/api/v1/controller-groups/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataControllerGroupRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerIds = jsonStrArray(j, "controllerIds");

      auto result = uc.createGroup(r);
      if (result.isSuccess()) {
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
      TenantId tenantId = req.getTenantId;
      auto items = uc.listGroups(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getGroup(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Controller group not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDataControllerGroupRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerIds = jsonStrArray(j, "controllerIds");

      auto result = uc.updateGroup(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteGroup(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const DataControllerGroup e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["isActive"] = Json(e.isActive);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);

    auto ids = Json.emptyArray;
    foreach (cid; e.controllerIds)
      ids ~= Json(cid);
    j["controllerIds"] = ids;

    return j;
  }
}
