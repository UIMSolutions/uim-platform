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

class InstanceController : PlatformController {
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
      r.tenantId = req.getTenantId;
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.size = j.getString("size");
      r.version_ = j.getString("version");
      r.region = j.getString("region");
      r.availabilityZone = j.getString("availabilityZone");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = j.getInteger("vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = j.getBoolean("enableScriptServer");
      r.enableDocStore = j.getBoolean("enableDocStore");
      r.enableDataLake = j.getBoolean("enableDataLake");
      r.allowAllIpAccess = j.getBoolean("allowAllIpAccess");
      r.whitelistedIps = getStringArray(j, "whitelistedIps");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Instance created");

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
      auto instances = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (instance; instances) {
        jarr ~= Json.emptyObject
          .set("id", instance.id)
          .set("name", instance.name)
          .set("description", instance.description)
          .set("status", instance.status.to!string)
          .set("version", instance.version_)
          .set("region", instance.region)
          .set("memoryGB", instance.resources.memoryGB)
          .set("vcpus", instance.resources.vcpus)
          .set("storageGB", instance.resources.storageGB)
          .set("createdAt", instance.createdAt)
          .set("updatedAt", instance.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(instances.length))
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
      auto instance = uc.getById(id);
      if (instance.isNull) {
        writeError(res, 404, "Instance not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", instance.id)
        .set("name", instance.name)
        .set("description", instance.description)
        .set("status", instance.status.to!string)
        .set("version", instance.version_)
        .set("region", instance.region)
        .set("availabilityZone", instance.availabilityZone)
        .set("memoryGB", instance.resources.memoryGB)
        .set("vcpus", instance.resources.vcpus)
        .set("storageGB", instance.resources.storageGB)
        .set("usedStorageGB", instance.resources.usedStorageGB)
        .set("enableScriptServer", instance.enableScriptServer)
        .set("enableDocStore", instance.enableDocStore)
        .set("enableDataLake", instance.enableDataLake)
        .set("allowAllIpAccess", instance.allowAllIpAccess)
        .set("whitelistedIps", stringsToJsonArray(i.whitelistedIps))
        .set("createdAt", instance.createdAt)
        .set("updatedAt", instance.updatedAt);

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
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = j.getInteger("vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = j.getBoolean("enableScriptServer");
      r.enableDocStore = j.getBoolean("enableDocStore");
      r.allowAllIpAccess = j.getBoolean("allowAllIpAccess");
      r.whitelistedIps = getStringArray(j, "whitelistedIps");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Instance updated");

        res.writeJsonBody(resp, 200);
      } else {
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
      r.tenantId = req.getTenantId;
      r.id = id;
      r.action = j.getString("action");

      auto result = uc.performAction(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Action performed: " ~ r.action);

        res.writeJsonBody(resp, 200);
      } else {
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
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
