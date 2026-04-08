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

class DataLakeController : SAPController {
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
      r.computeNodes = jsonInt(j, "computeNodes", 1);
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
      foreach (ref d; lakes) {
        auto dj = Json.emptyObject;
        dj["id"] = Json(d.id);
        dj["instanceId"] = Json(d.instanceId);
        dj["name"] = Json(d.name);
        dj["description"] = Json(d.description);
        dj["status"] = Json(d.status.to!string);
        dj["computeNodes"] = Json(cast(long) d.computeNodes);
        dj["createdAt"] = Json(d.createdAt);
        dj["modifiedAt"] = Json(d.modifiedAt);
        jarr ~= dj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) lakes.length);
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
      auto d = uc.get_(id);
      if (d.id.isEmpty) {
        writeError(res, 404, "Data lake not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(d.id);
      resp["instanceId"] = Json(d.instanceId);
      resp["name"] = Json(d.name);
      resp["description"] = Json(d.description);
      resp["status"] = Json(d.status.to!string);
      resp["computeNodes"] = Json(cast(long) d.computeNodes);
      resp["createdAt"] = Json(d.createdAt);
      resp["modifiedAt"] = Json(d.modifiedAt);
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
      r.computeNodes = jsonInt(j, "computeNodes", 1);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Data lake updated");
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
