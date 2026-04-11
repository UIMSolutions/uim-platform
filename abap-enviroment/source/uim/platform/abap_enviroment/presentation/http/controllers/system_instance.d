/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.http.controllers.system_instance;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;^
// 
// import uim.platform.abap_enviroment.application.usecases.manage.system_instances;
// import uim.platform.abap_enviroment.application.dto;
// import uim.platform.abap_enviroment.domain.entities.system_instance;
// import uim.platform.abap_enviroment.domain.types;

import uim.platform.abap_enviroment;

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
      request.abapRuntimeSize = jsonUshort(j, "abapRuntimeSize");
      request.hanaMemorySize = jsonUshort(j, "hanaMemorySize");
      request.softwareVersion = j.getString("softwareVersion");
      request.stackVersion = j.getString("stackVersion");

      auto result = uc.createInstance(request);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      auto arr = Json.emptyArray;
      foreach (inst; instances)
        arr ~= serializeInstance(inst);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(instances.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto inst = uc.getInstance(id);
      if (inst is null) {
        writeError(res, 404, "System instance not found");
        return;
      }
      res.writeJsonBody(serializeInstance(*inst), 200);
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
      r.abapRuntimeSize = jsonUshort(j, "abapRuntimeSize");
      r.hanaMemorySize = jsonUshort(j, "hanaMemorySize");
      r.softwareVersion = j.getString("softwareVersion");

      auto result = uc.updateInstance(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
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
        auto resp = Json.emptyObject;
        resp["status"] = Json("deleting");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeInstance(const SystemInstance instance) {
    return Json.emptyObject
      .set("id", instance.id)
      .set("tenantId", instance.tenantId)
      .set("subaccountId", instance.subaccountId)
      .set("name", instance.name)
      .set("description", instance.description)
      .set("plan", instance.plan.to!string)
      .set("status", instance.status.to!string)
      .set("region", instance.region)
      .set("sapSystemId", instance.sapSystemId)
      .set("adminEmail", instance.adminEmail)
      .set("abapRuntimeSize", instance.abapRuntimeSize)
      .set("hanaMemorySize", instance.hanaMemorySize)
      .set("serviceUrl", instance.serviceUrl)
      .set("softwareVersion", instance.softwareVersion)
      .set("stackVersion", instance.stackVersion)
      .set("createdAt", instance.createdAt)
      .set("updatedAt", instance.updatedAt);
  }
}
