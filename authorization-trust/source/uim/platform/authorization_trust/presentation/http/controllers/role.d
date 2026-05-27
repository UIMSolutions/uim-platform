/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.role;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class RoleController : ManageController {
  private ManageRolesUseCase usecase;

  this(ManageRolesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/roles",    &handleCreate);
    router.get("/api/v1/roles",     &handleList);
    router.get("/api/v1/roles/*",   &handleGet);
    router.put("/api/v1/roles/*",   &handleUpdate);
    router.delete_("/api/v1/roles/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateRoleRequest r;
      r.tenantId = tenantId;
      r.name        = data.getString("name");
      r.description = data.getString("description");
      r.appId       = data.getString("appId");

      auto srArr = j["scopeReferences"];
      if (srArr.type == Json.Type.array)
        foreach (v; srArr.byValue)
          r.scopeReferences ~= v.get!string;

      auto result = usecase.createRole(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto roles = usecase.listRoles(tenantId);
      auto jarr = Json.emptyArray;
      foreach (role; roles)
        jarr ~= role.toJson();
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", roles.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = RoleId(extractIdFromPath(req));
      
      auto role = usecase.getRole(tenantId, id);
      if (role.isNull) {
        writeError(res, 404, "Role not found");
        return;
      }
      res.writeJsonBody(role.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = RoleId(extractIdFromPath(req));
      auto data = precheck.data;
      UpdateRoleRequest r;
      r.tenantId = tenantId;
      r.id          = id;
      r.description = data.getString("description");

      auto srArr = j["scopeReferences"];
      if (srArr.type == Json.Type.array)
        foreach (v; srArr.byValue)
          r.scopeReferences ~= v.get!string;

      auto result = usecase.updateRole(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.message == "Role not found" ? 404 : 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = RoleId(extractIdFromPath(req));
      
      auto result = usecase.deleteRole(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id), 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
