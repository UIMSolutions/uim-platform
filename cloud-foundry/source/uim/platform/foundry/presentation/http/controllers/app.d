/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.foundry.application.usecases.manage.apps;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.application;

class AppController : PlatformController {
  private ManageAppsUseCase useCase;

  this(ManageAppsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    // Action routes (more specific — registered before wildcard)
    router.post("/api/v1/apps/start/*", &handleStart);
    router.post("/api/v1/apps/stop/*", &handleStop);
    router.post("/api/v1/apps/restart/*", &handleRestart);
    router.post("/api/v1/apps/scale/*", &handleScale);
    router.get("/api/v1/apps/env/*", &handleGetEnv);
    router.put("/api/v1/apps/env/*", &handleSetEnv);
    // CRUD wildcard
    router.get("/api/v1/apps/*", &handleGetById);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateAppRequest();
      r.tenantId = req.getTenantId;
      r.spaceId = j.getString("spaceId");
      r.name = j.getString("name");
      r.instances = j.getInteger("instances", 0);
      r.memoryMb = j.getInteger("memoryMb");
      r.diskMb = j.getInteger("diskMb");
      r.buildpackId = j.getString("buildpackId");
      r.stack = j.getString("stack");
      r.command = j.getString("command");
      r.healthCheckType = parseHealthCheckType(j.getString("healthCheckType"));
      r.healthCheckEndpoint = j.getString("healthCheckEndpoint");
      r.healthCheckTimeoutSec = j.getInteger("healthCheckTimeoutSec", 0);
      r.environmentVariables = j.getString("environmentVariables");
      r.dockerImage = j.getString("dockerImage");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createApp(r);
      if (result.isSuccess()) {
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
      auto apps = useCase.listApps(tenantId);

      auto arr = Json.emptyArray;
      foreach (a; apps)
        arr ~= serializeApp(a);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)apps.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto app = useCase.getApp(tenantId, id);
      if (app is null) {
        writeError(res, 404, "Application not found");
        return;
      }
      res.writeJsonBody(serializeApp(*app), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateAppRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.instances = j.getInteger("instances", 0);
      r.memoryMb = j.getInteger("memoryMb", 0);
      r.diskMb = j.getInteger("diskMb", 0);
      r.buildpackId = j.getString("buildpackId");
      r.stack = j.getString("stack");
      r.command = j.getString("command");
      r.healthCheckType = parseHealthCheckType(j.getString("healthCheckType"));
      r.healthCheckEndpoint = j.getString("healthCheckEndpoint");
      r.healthCheckTimeoutSec = j.getInteger("healthCheckTimeoutSec", 0);
      r.environmentVariables = j.getString("environmentVariables");
      r.dockerImage = j.getString("dockerImage");

      auto result = useCase.updateApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.startApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStop(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.stopApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRestart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.restartApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleScale(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = ScaleAppRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.instances = j.getInteger("instances", 0);
      r.memoryMb = j.getInteger("memoryMb", 0);
      r.diskMb = j.getInteger("diskMb", 0);

      auto result = useCase.scaleApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto env = useCase.getEnvironment(tenantId, id);

      auto resp = Json.emptyObject;
      resp["appId"] = Json(id);
      resp["environmentVariables"] = Json(env);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto j = req.json;
      auto envJson = j.getString("environmentVariables");

      auto result = useCase.setEnvironment(tenantId, id, envJson);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeApp(const Application a) {
    return Json.emptyObject
      .set("id", a.id)
      .set("spaceId", a.spaceId)
      .set("tenantId", a.tenantId)
      .set("name", a.name)
      .set("state", a.state.to!string)
      .set("instances", a.instances)
      .set("memoryMb", a.memoryMb)
      .set("diskMb", a.diskMb)
      .set("buildpackId", a.buildpackId)
      .set("detectedBuildpack", a.detectedBuildpack)
      .set("stack", a.stack)
      .set("command", a.command)
      .set("healthCheckType", a.healthCheckType.to!string)
      .set("healthCheckEndpoint", a.healthCheckEndpoint)
      .set("healthCheckTimeoutSec", a.healthCheckTimeoutSec)
      .set("environmentVariables", a.environmentVariables)
      .set("dockerImage", a.dockerImage)
      .set("dockerCredentials", a.dockerCredentials)
      .set("runningInstances", a.runningInstances)
      .set("createdBy", a.createdBy)
      .set("createdAt", a.createdAt)
      .set("updatedAt", a.updatedAt)
      .set("stagedAt", a.stagedAt);
  }
}
