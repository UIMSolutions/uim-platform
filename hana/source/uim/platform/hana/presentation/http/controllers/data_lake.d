/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.data_lake;

// import uim.platform.hana.application.usecases.manage.data_lakes;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class DataLakeController : PlatformController {
  private ManageDataLakesUseCase uc;

  this(ManageDataLakesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/dataLakes", &handleList);
    router.get("/api/v1/hana/dataLakes/*", &handleGet);
    router.post("/api/v1/hana/dataLakes", &handleCreate);
    router.put("/api/v1/hana/dataLakes/*", &handleUpdate);
    router.delete_("/api/v1/hana/dataLakes/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataLakeRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.computeNodes = j.getInteger("computeNodes", 1);
      r.storage = jsonKeyValuePairs(j, "storage");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Data lake created");
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
      auto lakes = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (d; lakes) {
        jarr ~= Json.emptyObject
        .set("id", d.id)
        .set("instanceId", d.instanceId)
        .set("name", d.name)
        .set("description", d.description)
        .set("status", d.status.to!string)
        .set("computeNodes", d.computeNodes)
        .set("createdAt", d.createdAt)
        .set("modifiedAt", d.modifiedAt);
      }

      auto resp = Json.emptyObject
      .set("count", Json(lakes.length))
      .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto d = uc.get_(id);
      if (d.id.isEmpty) {
        writeError(res, 404, "Data lake not found");
        return;
      }

      auto resp = Json.emptyObject
      .set("id", d.id)
      .set("instanceId", d.instanceId)
      .set("name", d.name)
      .set("description", d.description)
      .set("status", d.status.to!string)
      .set("computeNodes", d.computeNodes)
      .set("createdAt", d.createdAt)
      .set("modifiedAt", d.modifiedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateDataLakeRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.computeNodes = j.getInteger("computeNodes", 1);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Data lake updated");

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
