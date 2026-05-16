/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.role_collection;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class RoleCollectionController : PlatformController {
  private ManageRoleCollectionsUseCase usecase;

  this(ManageRoleCollectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/role-collections", &handleCreate);
    router.get("/api/v1/role-collections", &handleList);
    router.get("/api/v1/role-collections/*", &handleGet);
    router.put("/api/v1/role-collections/*", &handleUpdate);
    router.delete_("/api/v1/role-collections/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateRoleCollectionRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      foreach (v; j.getArray("roleReferences"))
        r.roleReferences ~= v.getString;

      auto result = usecase.createRoleCollection(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto rcs = usecase.listRoleCollections(tenantId);
      auto jarr = rcs.map!(rc => rc.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", rcs.length)
        .set("message", "Role collections retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RoleCollectionId(extractIdFromPath(req));
      
      auto rc = usecase.getRoleCollection(tenantId, id);
      if (rc.isNull) {
        writeError(res, 404, "Role collection not found");
        return;
      }
      auto response = Json.emptyObject
        .set("result", rc.toJson())
        .set("message", "Role collection retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RoleCollectionId(extractIdFromPath(req));
      auto j = req.json;

      UpdateRoleCollectionRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.description = j.getString("description");

      auto rrArr = j["roleReferences"];
      if (rrArr.type == Json.Type.array)
        foreach (v; rrArr.byValue)
          r.roleReferences ~= v.get!string;

      auto result = usecase.updateRoleCollection(r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", result.id)
          .set("message", "Role collection updated successfully");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, result.error == "Role collection not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RoleCollectionId(extractIdFromPath(req));

      auto result = usecase.deleteRoleCollection(tenantId, id);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", id)
          .set("message", "Role collection deleted successfully");
          
        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
