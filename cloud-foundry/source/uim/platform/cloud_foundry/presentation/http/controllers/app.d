module presentation.http.app;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_apps;
import application.dto;
import domain.types;
import domain.entities.application;
import presentation.http.json_utils;

class AppController
{
  private ManageAppsUseCase useCase;

  this(ManageAppsUseCase useCase)
  {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router)
  {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateAppRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = jsonStr(j, "spaceId");
      r.name = jsonStr(j, "name");
      r.instances = jsonInt(j, "instances");
      r.memoryMb = jsonInt(j, "memoryMb");
      r.diskMb = jsonInt(j, "diskMb");
      r.buildpackId = jsonStr(j, "buildpackId");
      r.stack = jsonStr(j, "stack");
      r.command = jsonStr(j, "command");
      r.healthCheckType = parseHealthCheckType(jsonStr(j, "healthCheckType"));
      r.healthCheckEndpoint = jsonStr(j, "healthCheckEndpoint");
      r.healthCheckTimeoutSec = jsonInt(j, "healthCheckTimeoutSec");
      r.environmentVariables = jsonStr(j, "environmentVariables");
      r.dockerImage = jsonStr(j, "dockerImage");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = useCase.createApp(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto apps = useCase.listApps(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref a; apps)
        arr ~= serializeApp(a);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) apps.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto app = useCase.getApp(id, tenantId);
      if (app is null)
      {
        writeError(res, 404, "Application not found");
        return;
      }
      res.writeJsonBody(serializeApp(*app), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateAppRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.instances = jsonInt(j, "instances");
      r.memoryMb = jsonInt(j, "memoryMb");
      r.diskMb = jsonInt(j, "diskMb");
      r.buildpackId = jsonStr(j, "buildpackId");
      r.stack = jsonStr(j, "stack");
      r.command = jsonStr(j, "command");
      r.healthCheckType = parseHealthCheckType(jsonStr(j, "healthCheckType"));
      r.healthCheckEndpoint = jsonStr(j, "healthCheckEndpoint");
      r.healthCheckTimeoutSec = jsonInt(j, "healthCheckTimeoutSec");
      r.environmentVariables = jsonStr(j, "environmentVariables");
      r.dockerImage = jsonStr(j, "dockerImage");

      auto result = useCase.updateApp(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.startApp(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleStop(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.stopApp(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRestart(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.restartApp(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleScale(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = ScaleAppRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.instances = jsonInt(j, "instances");
      r.memoryMb = jsonInt(j, "memoryMb");
      r.diskMb = jsonInt(j, "diskMb");

      auto result = useCase.scaleApp(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto env = useCase.getEnvironment(id, tenantId);

      auto resp = Json.emptyObject;
      resp["appId"] = Json(id);
      resp["environmentVariables"] = Json(env);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto j = req.json;
      auto envJson = jsonStr(j, "environmentVariables");

      auto result = useCase.setEnvironment(id, tenantId, envJson);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteApp(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeApp(ref const Application a)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["spaceId"] = Json(a.spaceId);
    j["tenantId"] = Json(a.tenantId);
    j["name"] = Json(a.name);
    j["state"] = Json(a.state.to!string);
    j["instances"] = Json(a.instances);
    j["memoryMb"] = Json(a.memoryMb);
    j["diskMb"] = Json(a.diskMb);
    j["buildpackId"] = Json(a.buildpackId);
    j["detectedBuildpack"] = Json(a.detectedBuildpack);
    j["stack"] = Json(a.stack);
    j["command"] = Json(a.command);
    j["healthCheckType"] = Json(a.healthCheckType.to!string);
    j["healthCheckEndpoint"] = Json(a.healthCheckEndpoint);
    j["healthCheckTimeoutSec"] = Json(a.healthCheckTimeoutSec);
    j["environmentVariables"] = Json(a.environmentVariables);
    j["dockerImage"] = Json(a.dockerImage);
    j["dockerCredentials"] = Json(a.dockerCredentials);
    j["runningInstances"] = Json(a.runningInstances);
    j["createdBy"] = Json(a.createdBy);
    j["createdAt"] = Json(a.createdAt);
    j["updatedAt"] = Json(a.updatedAt);
    j["stagedAt"] = Json(a.stagedAt);
    return j;
  }
}
