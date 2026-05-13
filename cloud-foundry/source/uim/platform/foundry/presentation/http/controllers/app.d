/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.app;



// import vibe.data.json;


// import uim.platform.foundry.application.usecases.manage.apps;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
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
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateAppRequest();
      r.tenantId = tenantId;
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
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = useCase.createApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

  protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
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

  protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateAppRequest();
      r.id = appId;
      r.tenantId = tenantId;
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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.startApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Application started successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetStop(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.stopApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetRestart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.restartApp(tenantId, appId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetScale(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = AppId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = ScaleAppRequest();
      r.id = appId;
      r.tenantId = tenantId;
      r.instances = j.getInteger("instances", 0);
      r.memoryMb = j.getInteger("memoryMb", 0);
      r.diskMb = j.getInteger("diskMb", 0);

      auto result = useCase.scaleApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("id", result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetGetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto env = useCase.getEnvironment(tenantId, id);

      auto resp = Json.emptyObject
      .set("appId", id)
      .set("environmentVariables", env);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetSetEnv(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto envJson = j.getString("environmentVariables");

      auto result = useCase.setEnvironment(tenantId, id, envJson);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AppId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
