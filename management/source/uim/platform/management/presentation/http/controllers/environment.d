/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.environment;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.environment_instances;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.environment_instance;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class EnvironmentController : PlatformController {
  private ManageEnvironmentInstancesUseCase uc;

  this(ManageEnvironmentInstancesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/environments", &handleCreate);
    router.get("/api/v1/environments", &handleList);
    router.get("/api/v1/environments/*", &handleGet);
    router.put("/api/v1/environments/*", &handleUpdate);
    router.post("/api/v1/environments/deprovision/*", &handleDeprovision);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateEnvironmentInstanceRequest r;
      r.subaccountId = j.getString("subaccountId");
      r.globalAccountId = j.getString("globalAccountId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.environmentType = j.getString("environmentType");
      r.planName = j.getString("planName");
      r.landscapeLabel = j.getString("landscapeLabel");
      r.memoryQuotaMb = j.getInteger("memoryQuotaMb");
      r.routeQuota = j.getInteger("routeQuota");
      r.serviceQuota = j.getInteger("serviceQuota");
      r.createdBy = req.headers.get("X-User-Id", "");
      r.parameters = jsonStrMap(j, "parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto subId = req.params.get("subaccountId");
      auto envType = req.params.get("environmentType");

      EnvironmentInstance[] items;
      if (envType.length > 0 && subId.length > 0)
        items = uc.listByType(subId, envType);
      else if (subId.length > 0)
        items = uc.listBySubaccount(subId);

      auto arr = Json.emptyArray;
      foreach (inst; items)
        arr ~= serializeEnvironment(inst);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto inst = uc.getById(id);
      if (inst.id.isEmpty) {
        writeError(res, 404, "Environment instance not found");
        return;
      }
      res.writeJsonBody(serializeEnvironment(inst), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateEnvironmentInstanceRequest request;
      request.description = j.getString("description");
      request.memoryQuotaMb = j.getInteger("memoryQuotaMb");
      request.routeQuota = j.getInteger("routeQuota");
      request.serviceQuota = j.getInteger("serviceQuota");
      request.parameters = jsonStrMap(j, "parameters");
      request.labels = jsonStrMap(j, "labels");

      auto result = uc.update(id, request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDeprovision(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.deprovision(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeEnvironment(EnvironmentInstance inst) {
  return Json.emptyObject
    .set("id", inst.id)
    .set("subaccountId", inst.subaccountId)
    .set("globalAccountId", inst.globalAccountId)
    .set("name", inst.name)
    .set("description", inst.description)
    .set("environmentType", to!string(inst.environmentType))
    .set("status", to!string(inst.status))
    .set("planName", inst.planName)
    .set("landscapeLabel", inst.landscapeLabel)
    .set("technicalKey", inst.technicalKey)
    .set("dashboardUrl", inst.dashboardUrl)
    .set("memoryQuotaMb", inst.memoryQuotaMb)
    .set("routeQuota", inst.routeQuota)
    .set("serviceQuota", inst.serviceQuota)
    .set("createdBy", inst.createdBy)
    .set("createdAt", inst.createdAt)
    .set("modifiedAt", inst.modifiedAt)
    .set("parameters", inst.parameters)
    .set("labels", inst.labels);
}


