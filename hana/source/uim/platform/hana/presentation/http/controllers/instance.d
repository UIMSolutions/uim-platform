/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.instance;
// import uim.platform.hana.application.usecases.manage.instances;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class InstanceController : ManageController {
  private ManageInstancesUseCase usecase;

  this(ManageInstancesUseCase usecase) {
    this.usecase = usecase;
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateInstanceRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.size = data.getString("size");
      r.version_ = data.getString("version");
      r.region = data.getString("region");
      r.availabilityZone = data.getString("availabilityZone");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = data.getInteger("vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = data.getBoolean("enableScriptServer");
      r.enableDocStore = data.getBoolean("enableDocStore");
      r.enableDataLake = data.getBoolean("enableDataLake");
      r.allowAllIpAccess = data.getBoolean("allowAllIpAccess");
      r.whitelistedIps = data.getStrings("whitelistedIps");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Instance created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto instances = usecase.list(tenantId);

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
        .set("resources", list);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto instance = usecase.getById(tenantId, id);
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto data = precheck.data;
      UpdateInstanceRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.memoryGB = jsonLong(j, "memoryGB");
      r.vcpus = data.getInteger("vcpus");
      r.storageGB = jsonLong(j, "storageGB");
      r.enableScriptServer = data.getBoolean("enableScriptServer");
      r.enableDocStore = data.getBoolean("enableDocStore");
      r.allowAllIpAccess = data.getBoolean("allowAllIpAccess");
      r.whitelistedIps = data.getStrings("whitelistedIps");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Instance updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAction(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      
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

      auto data = precheck.data;
      InstanceActionRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.action = data.getString("action");

      auto result = usecase.performAction(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Action performed: " ~ r.action);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = InstanceId(precheck.id);
      auto result = usecase.deleteInstance(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
