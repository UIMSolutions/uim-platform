/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.mobile_app;

import uim.platform.mobile.application.usecases.manage.mobile_apps;
import uim.platform.mobile.application.dto;

import uim.platform.mobile;



class MobileAppController : PlatformController {
  private ManageMobileAppsUseCase usecase;

  this(ManageMobileAppsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateMobileAppRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.bundleId = j.getString("bundleId");
      r.platform = j.getString("platform");
      r.securityConfig = j.getString("securityConfig");
      r.authProvider = j.getString("authProvider");
      r.pushEnabled = j.getBoolean("pushEnabled");
      r.offlineEnabled = j.getBoolean("offlineEnabled");
      r.iconUrl = j.getString("iconUrl");
      r.createdBy = UserId(j.getString("createdBy"));
      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("name", item.name)
          .set("bundleId", item.bundleId)
          .set("platform", item.platform)
          .set("status", item.status);
      }
      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", Json(results.length))
        .set("message", "Mobile apps retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = usecase.get(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("name", result.data.name)
          .set("description", result.data.description)
          .set("bundleId", result.data.bundleId)
          .set("platform", result.data.platform)
          .set("securityConfig", result.data.securityConfig)
          .set("authProvider", result.data.authProvider)
          .set("pushEnabled", result.data.pushEnabled)
          .set("offlineEnabled", result.data.offlineEnabled)
          .set("iconUrl", result.data.iconUrl)
          .set("status", result.data.status)
          .set("createdBy", result.data.createdBy)
          .set("message", "Mobile app retrieved successfully");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateMobileAppRequest r;
      r.id = id;
      r.description = j.getString("description");
      r.securityConfig = j.getString("securityConfig");
      r.authProvider = j.getString("authProvider");
      r.status = j.getString("status");
      r.pushEnabled = j.getBoolean("pushEnabled");
      r.offlineEnabled = j.getBoolean("offlineEnabled");
      r.iconUrl = j.getString("iconUrl");
      r.updatedBy = UserId(j.getString("updatedBy"));
      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Mobile app updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = MobileAppId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteMobileApp(id);
      if (result.success) {
        res.writeBody("", 204);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
