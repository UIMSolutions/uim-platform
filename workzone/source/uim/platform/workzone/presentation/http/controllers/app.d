/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.app;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.workzone.application.usecases.manage.apps;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.app_registration;
import uim.platform.workzone;

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
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateAppRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.launchUrl = j.getString("launchUrl");
      r.icon = j.getString("icon");
      r.vendor = j.getString("vendor");
      r.version_ = j.getString("version");
      r.supportedPlatforms = getStringArray(j, "supportedPlatforms");
      r.tags = getStringArray(j, "tags");
      r.appConfig = parseAppConfig(j);

      auto result = useCase.createApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App created");

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
      auto apps = useCase.listApps(tenantId);
      auto arr = apps.map!(a => a.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", arr);
      
      .set("totalCount", Json(apps.length))
        .set("message", "Apps retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = AppId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      auto app = useCase.getApp(tenantId, id);
      if (app.isNull) {
        writeError(res, 404, "App not found");
        return;
      }
      res.writeJsonBody(app.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateAppRequest();
      r.id = AppId(extractIdFromPath(req.requestURI));
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.launchUrl = j.getString("launchUrl");
      r.icon = j.getString("icon");
      r.appConfig = parseAppConfig(j);

      auto sStr = j.getString("status");
      if (sStr == "inactive")
        r.status = AppStatus.inactive;
      else if (sStr == "deprecated")
        r.status = AppStatus.deprecated_;
      else
        r.status = AppStatus.active;

      auto result = useCase.updateApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private AppConfig parseAppConfig(Json j) {
  import uim.platform.workzone.domain.entities.app_registration : AppConfig;

  AppConfig cfg;
  if ("appConfig" in j && j["appConfig"].isObject) {
    auto c = j["appConfig"];
    cfg.authType = c.getString("authType");
    cfg.authEndpoint = c.getString("authEndpoint");
    cfg.enableSso = getBoolean(c, "enableSso");
    cfg.sapSystemAlias = c.getString("sapSystemAlias");
    cfg.oDataServiceUrl = c.getString("oDataServiceUrl");
    cfg.componentId = c.getString("componentId");
  }
  return cfg;
}
