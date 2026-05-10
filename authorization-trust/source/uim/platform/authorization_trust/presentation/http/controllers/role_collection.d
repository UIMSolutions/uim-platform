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
    router.post("/api/v1/role-collections",    &handleCreate);
    router.get("/api/v1/role-collections",     &handleList);
    router.get("/api/v1/role-collections/*",   &handleGet);
    router.put("/api/v1/role-collections/*",   &handleUpdate);
    router.delete_("/api/v1/role-collections/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateRoleCollectionRequest r;
      r.name        = j.getString("name");
      r.description = j.getString("description");

      auto rrArr = j["roleReferences"];
      if (rrArr.type == Json.Type.array)
        foreach (v; rrArr.byValue)
          r.roleReferences ~= v.get!string;

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
      auto rcs = usecase.listAll();
      auto jarr = Json.emptyArray;
      foreach (rc; rcs)
        jarr ~= rcToJson(rc);
      res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", rcs.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto rc = usecase.getById(id);
      if (rc.id.length == 0) {
        writeError(res, 404, "Role collection not found");
        return;
      }
      res.writeJsonBody(rcToJson(rc), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req);
      auto j = req.json;
      UpdateRoleCollectionRequest r;
      r.id          = id;
      r.description = j.getString("description");

      auto rrArr = j["roleReferences"];
      if (rrArr.type == Json.Type.array)
        foreach (v; rrArr.byValue)
          r.roleReferences ~= v.get!string;

      auto result = usecase.update(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, result.error == "Role collection not found" ? 404 : 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
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

  private Json rcToJson(RoleCollectionEntity rc) @safe {
    auto rrArr = Json.emptyArray;
    foreach (r; rc.roleReferences)
      rrArr ~= Json(r);

    return Json.emptyObject
      .set("id",             rc.id)
      .set("name",           rc.name)
      .set("description",    rc.description)
      .set("roleReferences", rrArr)
      .set("createdAt",      rc.createdAt)
      .set("updatedAt",      rc.updatedAt);
  }
}
