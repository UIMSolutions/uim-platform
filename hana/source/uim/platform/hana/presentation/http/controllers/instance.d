/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.instance;

// import uim.platform.hana.application.usecases.manage.instances;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class InstanceController : SAPController {
  private ManageInstancesUseCase uc;

  this(ManageInstancesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/instances", &handleList);
    router.get("/api/v1/hana/instances/*", &handleGet);
    router.post("/api/v1/hana/instances", &handleCreate);
    router.put("/api/v1/hana/instances/*", &handleUpdate);
    router.post("/api/v1/hana/instances/*/action", &handleAction);
    router.delete_("/api/v1/hana/instances/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateInstanceRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.size = j.getString("size");
      r.version_ = j.getString("version");
      r.region = j.getString("region");
      r.availabilityZone = j.getString("availabilityZone");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = jsonInt(j, "vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = jsonBool(j, "enableScriptServer");
      r.enableDocStore = jsonBool(j, "enableDocStore");
      r.enableDataLake = jsonBool(j, "enableDataLake");
      r.allowAllIpAccess = jsonBool(j, "allowAllIpAccess");
      r.whitelistedIps = jsonStrArray(j, "whitelistedIps");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Instance created");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto instances = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref i; instances) {
        auto ij = Json.emptyObject;
        ij["id"] = Json(i.id);
        ij["name"] = Json(i.name);
        ij["description"] = Json(i.description);
        ij["status"] = Json(i.status.to!string);
        ij["version"] = Json(i.version_);
        ij["region"] = Json(i.region);
        ij["memoryGB"] = Json(i.resources.memoryGB);
        ij["vcpus"] = Json(cast(long) i.resources.vcpus);
        ij["storageGB"] = Json(i.resources.storageGB);
        ij["createdAt"] = Json(i.createdAt);
        ij["modifiedAt"] = Json(i.modifiedAt);
        jarr ~= ij;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) instances.length);
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
      auto i = uc.get_(id);
      if (i.id.length == 0) {
        writeError(res, 404, "Instance not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(i.id);
      resp["name"] = Json(i.name);
      resp["description"] = Json(i.description);
      resp["status"] = Json(i.status.to!string);
      resp["version"] = Json(i.version_);
      resp["region"] = Json(i.region);
      resp["availabilityZone"] = Json(i.availabilityZone);
      resp["memoryGB"] = Json(i.resources.memoryGB);
      resp["vcpus"] = Json(cast(long) i.resources.vcpus);
      resp["storageGB"] = Json(i.resources.storageGB);
      resp["usedStorageGB"] = Json(i.resources.usedStorageGB);
      resp["enableScriptServer"] = Json(i.enableScriptServer);
      resp["enableDocStore"] = Json(i.enableDocStore);
      resp["enableDataLake"] = Json(i.enableDataLake);
      resp["allowAllIpAccess"] = Json(i.allowAllIpAccess);
      resp["whitelistedIps"] = stringsToJsonArray(i.whitelistedIps);
      resp["createdAt"] = Json(i.createdAt);
      resp["modifiedAt"] = Json(i.modifiedAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateInstanceRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = jsonInt(j, "vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = jsonBool(j, "enableScriptServer");
      r.enableDocStore = jsonBool(j, "enableDocStore");
      r.allowAllIpAccess = jsonBool(j, "allowAllIpAccess");
      r.whitelistedIps = jsonStrArray(j, "whitelistedIps");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Instance updated");
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      // extract id from /api/v1/hana/instances/{id}/action
      auto actionIdx = lastIndexOf(path, "/action");
      if (actionIdx < 0) {
        writeError(res, 400, "Invalid action path");
        return;
      }
      auto sub = path[0 .. actionIdx];
      auto id = extractIdFromPath(sub);

      auto j = req.json;
      InstanceActionRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = id;
      r.action = j.getString("action");

      auto result = uc.performAction(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Action performed: " ~ r.action);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
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
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
