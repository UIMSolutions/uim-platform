/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.app;

// import uim.platform.foundry.application.usecases.manage.apps;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class AppController : ManageController {
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
    router.get("/api/v1/apps/env/*", &handleEnv);
    router.put("/api/v1/apps/env/*", &handleSetEnv);
    // CRUD wildcard
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateAppRequest();
      r.tenantId = tenantId;
      r.spaceId = data.getString("spaceId");
      r.name = data.getString("name");
      r.instances = data.getInteger("instances", 0);
      r.memoryMb = data.getInteger("memoryMb");
      r.diskMb = data.getInteger("diskMb");
      r.buildpackId = data.getString("buildpackId");
      r.stack = data.getString("stack");
      r.command = data.getString("command");
      r.healthCheckType = data.getString("healthCheckType");
      r.healthCheckEndpoint = data.getString("healthCheckEndpoint");
      r.healthCheckTimeoutSec = data.getInteger("healthCheckTimeoutSec", 0);
      r.environmentVariables = data.getString("environmentVariables");
      r.dockerImage = data.getString("dockerImage");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto apps = useCase.listApps(tenantId);

      auto arr = apps.map!(a => a.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", apps.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto app = useCase.getApp(tenantId, appId);
      if (app.isNull) {
        writeError(res, 404, "Application not found");
        return;
      }

      res.writeJsonBody(app.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto data = precheck.data;
      auto r = UpdateAppRequest();
      r.id = appId;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.instances = data.getInteger("instances", 0);
      r.memoryMb = data.getInteger("memoryMb", 0);
      r.diskMb = data.getInteger("diskMb", 0);
      r.buildpackId = data.getString("buildpackId");
      r.stack = data.getString("stack");
      r.command = data.getString("command");
      r.healthCheckType = data.getString("healthCheckType");
      r.healthCheckEndpoint = data.getString("healthCheckEndpoint");
      r.healthCheckTimeoutSec = data.getInteger("healthCheckTimeoutSec", 0);
      r.environmentVariables = data.getString("environmentVariables");
      r.dockerImage = data.getString("dockerImage");

      auto result = useCase.updateApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.startApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application started successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleStop(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.stopApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleRestart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.restartApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleScale(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(precheck.id);
      auto data = precheck.data;
      auto r = ScaleAppRequest();
      r.id = appId;
      r.tenantId = tenantId;
      r.instances = data.getInteger("instances", 0);
      r.memoryMb = data.getInteger("memoryMb", 0);
      r.diskMb = data.getInteger("diskMb", 0);

      auto result = useCase.scaleApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto env = useCase.getEnvironment(tenantId, id);

      auto resp = Json.emptyObject
        .set("appId", id)
        .set("environmentVariables", env);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto envJson = data.getString("environmentVariables");

      auto result = useCase.setEnvironment(tenantId, id, envJson);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
