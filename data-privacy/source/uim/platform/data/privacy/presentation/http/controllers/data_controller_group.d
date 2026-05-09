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
  private ManageDataControllerGroupsUseCase usecase;

  this(ManageDataControllerGroupsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/controller-groups", &handleCreate);
    router.get("/api/v1/controller-groups", &handleList);
    router.get("/api/v1/controller-groups/*", &handleGet);
    router.put("/api/v1/controller-groups/*", &handleUpdate);
    router.delete_("/api/v1/controller-groups/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDataControllerGroupRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerIds = getStrings(j, "controllerIds").map!(cid => DataControllerId(cid)).array;

      auto result = usecase.createGroup(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data controller group created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = usecase.listGroups(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Data controller groups retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataControllerGroupId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto entry = usecase.getGroup(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Controller group not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto tenantId = req.getTenantId;
        auto id = DataControllerGroupId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateDataControllerGroupRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerIds = getStrings(j, "controllerIds").map!(cid => DataControllerId(cid)).array;

      auto result = usecase.updateGroup(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data controller group updated successfully");
            
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataControllerGroupId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      usecase.deleteGroup(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const DataControllerGroup e) {
    auto ids = e.controllerIds.map!(cid => cid.value).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("name", e.name)
      .set("description", e.description)
      .set("isActive", e.isActive)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("controllerIds", ids);
  }
}
