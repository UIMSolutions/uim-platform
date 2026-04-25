/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.hdi_container;

// import uim.platform.hana.application.usecases.manage.hdi_containers;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;
import uim.platform.hana;

mixin(ShowModule!());

@safe:

class HDIContainerController : PlatformController {
  private ManageHDIContainersUseCase uc;

  this(ManageHDIContainersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/hdiContainers", &handleList);
    router.get("/api/v1/hana/hdiContainers/*", &handleGet);
    router.post("/api/v1/hana/hdiContainers", &handleCreate);
    router.put("/api/v1/hana/hdiContainers/*", &handleUpdate);
    router.delete_("/api/v1/hana/hdiContainers/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateHDIContainerRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.appUser = j.getString("appUser");
      r.grantedSchemas = getStringArray(j, "grantedSchemas");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("HDI Container created");
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
      TenantId tenantId = req.getTenantId;
      auto containers = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; containers) {
        jarr ~= Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("name", c.name)
        .set("status", c.status.to!string)
        .set("artifactCount", c.artifactCount)
        .set("sizeBytes", c.sizeBytes)
        .set("createdAt", c.createdAt);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(containers.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto c = uc.getById(id);
      if (c.id.isEmpty) {
        writeError(res, 404, "HDI Container not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(c.id);
      resp["instanceId"] = Json(c.instanceId);
      resp["name"] = Json(c.name);
      resp["description"] = Json(c.description);
      resp["status"] = Json(c.status.to!string);
      resp["schemaName"] = Json(c.schemaName);
      resp["appUser"] = Json(c.appUser);
      resp["artifactCount"] = Json(c.artifactCount);
      resp["sizeBytes"] = Json(c.sizeBytes);
      resp["grantedSchemas"] = stringsToJsonArray(c.grantedSchemas);
      resp["createdAt"] = Json(c.createdAt);
      resp["updatedAt"] = Json(c.updatedAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateHDIContainerRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.grantedSchemas = getStringArray(j, "grantedSchemas");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("HDI Container updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
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
