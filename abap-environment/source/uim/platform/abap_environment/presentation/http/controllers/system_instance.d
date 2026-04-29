/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.http.controllers.system_instance;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;^
// 
// import uim.platform.abap_environment.application.usecases.manage.system_instances;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class SystemInstanceController : PlatformController {
  private ManageSystemInstancesUseCase uc;

  this(ManageSystemInstancesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/systems", &handleCreate);
    router.get("/api/v1/systems", &handleList);
    router.get("/api/v1/systems/*", &handleGetById);
    router.put("/api/v1/systems/*", &handleUpdate);
    router.delete_("/api/v1/systems/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSystemInstanceRequest request;
      request.tenantId = req.getTenantId;
      request.subaccountId = j.getString("subaccountId");
      request.name = j.getString("name");
      request.description = j.getString("description");
      request.plan = j.getString("plan");
      request.region = j.getString("region");
      request.sapSystemId = j.getString("sapSystemId");
      request.adminEmail = j.getString("adminEmail");
      request.abapRuntimeSize = getUshort(j, "abapRuntimeSize");
      request.hanaMemorySize = getUshort(j, "hanaMemorySize");
      request.softwareVersion = j.getString("softwareVersion");
      request.stackVersion = j.getString("stackVersion");

      auto result = uc.createInstance(request);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "System instance creation initiated");  

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
      auto instances = uc.listInstances(tenantId);
      auto arr = instances.map!(inst => inst.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(instances.length))
        .set("message", "System instances retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto inst = uc.getInstance(id);
      if (inst.isNull) {
        writeError(res, 404, "System instance not found");
        return;
      }
      res.writeJsonBody(inst.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateSystemInstanceRequest r;
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.abapRuntimeSize = getUshort(j, "abapRuntimeSize");
      r.hanaMemorySize = getUshort(j, "hanaMemorySize");
      r.softwareVersion = j.getString("softwareVersion");

      auto result = uc.updateInstance(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "System instance updated");

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
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteInstance(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleting")
          .set("message", "System instance deletion initiated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
