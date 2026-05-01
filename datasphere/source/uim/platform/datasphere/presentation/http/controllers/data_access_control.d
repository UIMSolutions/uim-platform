/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_access_control;

// import uim.platform.datasphere.application.usecases.manage.data_access_controls;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class DataAccessControlController : PlatformController {
  private ManageDataAccessControlsUseCase uc;

  this(ManageDataAccessControlsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/datasphere/dataAccessControls", &handleList);
    router.get("/api/v1/datasphere/dataAccessControls/*", &handleGet);
    router.post("/api/v1/datasphere/dataAccessControls", &handleCreate);
    router.delete_("/api/v1/datasphere/dataAccessControls/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataAccessControlRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.criteriaType = j.getString("criteriaType");
      r.targetViewIds = j.getArray("targetViewIds").map!(v => ViewId(v.to!string)).array;
      r.assignedUserIds = j.getArray("assignedUserIds").map!(v => UserId(v.to!string)).array;

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data access control created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto controls = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (dac; controls) {
        jarr ~= Json.emptyObject
          .set("id", dac.id)
          .set("name", dac.name)
          .set("description", dac.description)
          .set("isEnabled", dac.isEnabled)
          .set("createdAt", dac.createdAt);
      }

      auto resp = Json.emptyObject
            .set("count", controls.length)
            .set("resources", jarr)
            .set("message", "Data access controls retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = DataAccessControlId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto dac = uc.getById(spaceId, id);
      if (dac.id.isEmpty) {
        writeError(res, 404, "Data access control not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", dac.id)
            .set("name", dac.name)
            .set("description", dac.description)
            .set("isEnabled", dac.isEnabled)
            .set("targetViewIds", dac.targetViewIds.map!(v => v.toJson).array.toJson)
            .set("assignedUserIds", dac.assignedUserIds.map!(v => v.toJson).array.toJson)
            .set("createdAt", dac.createdAt)
            .set("updatedAt", dac.updatedAt)
            .set("message", "Data access control retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = DataAccessControlId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = uc.remove(spaceId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
