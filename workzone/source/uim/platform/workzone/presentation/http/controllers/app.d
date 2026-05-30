/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.app;



// import uim.platform.workzone.application.usecases.manage.apps;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.app_registration;
import uim.platform.workzone;

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
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateAppRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.launchUrl = data.getString("launchUrl");
      r.icon = data.getString("icon");
      r.vendor = data.getString("vendor");
      r.version_ = data.getString("version");
      r.supportedPlatforms = data.getStrings("supportedPlatforms");
      r.tags = data.getStrings("tags");
      r.appConfig = parseAppConfig(j);

      auto result = useCase.createApp(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
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

      auto response = Json.emptyObject
        .set("items", arr);
      
      .set("totalCount", Json(apps.length))
        .set("message", "Apps retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = AppId(precheck.id);
      auto tenantId = precheck.tenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateAppRequest();
      r.id = AppId(precheck.id);
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.launchUrl = data.getString("launchUrl");
      r.icon = data.getString("icon");
      r.appConfig = parseAppConfig(j);

      auto sStr = data.getString("status");
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
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteApp(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
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
