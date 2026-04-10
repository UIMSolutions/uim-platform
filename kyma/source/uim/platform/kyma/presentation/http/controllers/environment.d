/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.environment;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.environments;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_environment;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class EnvironmentController : PlatformController{
  private ManageEnvironmentsUseCase uc;

  this(ManageEnvironmentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/environments", &handleCreate);
    router.get("/api/v1/environments", &handleList);
    router.get("/api/v1/environments/*", &handleGetById);
    router.put("/api/v1/environments/*", &handleUpdate);
    router.delete_("/api/v1/environments/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateEnvironmentRequest r;
      r.tenantId = req.getTenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.plan = j.getString("plan");
      r.region = j.getString("region");
      r.machineCount = j.getInteger("machineCount");
      r.machineType = j.getString("machineType");
      r.autoScalerMin = j.getInteger("autoScalerMin");
      r.autoScalerMax = j.getInteger("autoScalerMax");
      r.oidcIssuerUrl = j.getString("oidcIssuerUrl");
      r.oidcClientId = j.getString("oidcClientId");
      r.oidcGroupsClaim = jsonStrArray(j, "oidcGroupsClaim");
      r.oidcUsernameClaim = jsonStrArray(j, "oidcUsernameClaim");
      r.administrators = jsonStrArray(j, "administrators");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto subaccountId = req.headers.get("X-Subaccount-Id", "");

      KymaEnvironment[] envs;
      if (subaccountId.length > 0)
        envs = uc.listBySubaccount(tenantId, subaccountId);
      else
        envs = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; envs)
        arr ~= serializeEnv(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) envs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto env = uc.getEnvironment(id);
      if (env.id.isEmpty) {
        writeError(res, 404, "Environment not found");
        return;
      }
      res.writeJsonBody(serializeEnv(env), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateEnvironmentRequest r;
      r.description = j.getString("description");
      r.machineCount = j.getInteger("machineCount");
      r.machineType = j.getString("machineType");
      r.autoScalerMin = j.getInteger("autoScalerMin");
      r.autoScalerMax = j.getInteger("autoScalerMax");
      r.oidcIssuerUrl = j.getString("oidcIssuerUrl");
      r.oidcClientId = j.getString("oidcClientId");
      r.administrators = jsonStrArray(j, "administrators");

      auto result = uc.updateEnvironment(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteEnvironment(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeEnv(ref KymaEnvironment e) {
    return Json.emptyObject
    .set("id", Json(e.id))
    .set("tenantId", Json(e.tenantId))
    .set("subaccountId", Json(e.subaccountId))
    .set("clusterId", Json(e.clusterId))
    .set("name", Json(e.name))
    .set("description", Json(e.description))
    .set("plan", Json(e.plan.to!string))
    .set("region", Json(e.region))
    .set("kubernetesVersion", Json(e.kubernetesVersion))
    .set("status", Json(e.status.to!string))
    .set("machineCount", Json(cast(long) e.machineCount))
    .set("machineType", Json(e.machineType))
    .set("autoScalerMin", Json(cast(long) e.autoScalerMin))
    .set("autoScalerMax", Json(cast(long) e.autoScalerMax))
    .set("shootDomain", Json(e.shootDomain))
    .set("kubeApiServerUrl", Json(e.kubeApiServerUrl))
    .set("administrators", serializeStrArray(e.administrators))
    .set("createdBy", Json(e.createdBy))
    .set("createdAt", Json(e.createdAt))
    .set("modifiedAt", Json(e.modifiedAt));
  }
}
