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
class EnvironmentController : PlatformController {
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
      r.oidcGroupsClaim = getStringArray(j, "oidcGroupsClaim");
      r.oidcUsernameClaim = getStringArray(j, "oidcUsernameClaim");
      r.administrators = getStringArray(j, "administrators");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto subaccountId = req.headers.get("X-Subaccount-Id", "");

      KymaEnvironment[] envs;
      if (subaccountId.length > 0)
        envs = uc.listBySubaccount(tenantId, SubaccountId(subaccountId));
      else
        envs = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; envs)
        arr ~= serializeEnv(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(envs.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      if (!uc.hasEnvironment(KymaEnvironmentId(id))) {
        writeError(res, 404, "Environment not found");
        return;
      }

      auto env = uc.getEnvironment(KymaEnvironmentId(id));
      res.writeJsonBody(serializeEnv(env), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateEnvironmentRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.machineCount = j.getInteger("machineCount");
      r.machineType = j.getString("machineType");
      r.autoScalerMin = j.getInteger("autoScalerMin");
      r.autoScalerMax = j.getInteger("autoScalerMax");
      r.oidcIssuerUrl = j.getString("oidcIssuerUrl");
      r.oidcClientId = j.getString("oidcClientId");
      r.administrators = getStringArray(j, "administrators");

      auto result = uc.updateEnvironment(KymaEnvironmentId(id), r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteEnvironment(KymaEnvironmentId(id));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeEnv(KymaEnvironment e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("subaccountId", e.subaccountId)
      .set("clusterId", e.clusterId)
      .set("name", e.name)
      .set("description", e.description)
      .set("plan", e.plan.to!string)
      .set("region", e.region)
      .set("kubernetesVersion", e.kubernetesVersion)
      .set("status", e.status.to!string)
      .set("machineCount", e.machineCount)
      .set("machineType", e.machineType)
      .set("autoScalerMin", e.autoScalerMin)
      .set("autoScalerMax", e.autoScalerMax)
      .set("shootDomain", e.shootDomain)
      .set("kubeApiServerUrl", e.kubeApiServerUrl)
      .set("administrators", e.administrators.toJson)
      .set("createdBy", e.createdBy)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt);
  }
}
