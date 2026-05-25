/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.group_;



// import uim.platform.workzone.application.usecases.manage.manage.groups;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.group;
// import uim.platform.identity.authentication.presentation.http
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class GroupController : ManageController {
  private ManageGroupsUseCase useCase;

  this(ManageGroupsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/groups", &handleCreate);
    router.get("/api/v1/groups", &handleList);
    router.get("/api/v1/groups/*", &handleGet);
    router.put("/api/v1/groups/*", &handleUpdate);
    router.delete_("/api/v1/groups/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateGroupRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = useCase.createGroup(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "WZGroup created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto groups = useCase.listGroups(tenantId);
      auto arr = groups.map!(g => g.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(groups.length))
        .set("message", "Groups retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto g = useCase.getGroup(tenantId, id);
      if (g.isNull) {
        writeError(res, 404, "WZGroup not found");
        return;
      }
      res.writeJsonBody(g.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateGroupRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.active = j.getBoolean("active", true);

      auto result = useCase.updateGroup(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "WZGroup updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteGroup(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "WZGroup deleted");
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
