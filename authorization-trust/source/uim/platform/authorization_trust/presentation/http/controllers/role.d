/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.role;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class RoleController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateRoleRequest r;
      r.name        = j.getString("name");
      r.description = j.getString("description");
      r.appId       = j.getString("appId");

      auto srArr = j["scopeReferences"];
      if (srArr.type == Json.Type.array)
        foreach (v; srArr.byValue)
          r.scopeReferences ~= v.get!string;

      auto result = usecase.create(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto roles = usecase.listAll();
      auto jarr = Json.emptyArray;
      foreach (role; roles)
        jarr ~= roleToJson(role);
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", roles.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req);
      auto role = usecase.getById(id);
      if (role.id.length == 0) {
        writeError(res, 404, "Role not found");
        return;
      }
      res.writeJsonBody(roleToJson(role), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req);
      auto j = req.json;
      UpdateRoleRequest r;
      r.id          = id;
      r.description = j.getString("description");

      auto srArr = j["scopeReferences"];
      if (srArr.type == Json.Type.array)
        foreach (v; srArr.byValue)
          r.scopeReferences ~= v.get!string;

      auto result = usecase.update(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.error == "Role not found" ? 404 : 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req);
      auto result = usecase.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id), 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
