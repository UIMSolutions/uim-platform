/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.app_configuration;
// import uim.platform.mobile.application.usecases.manage.app_configurations;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class AppConfigurationController : ManageController {
  private ManageAppConfigurationsUseCase usecase;

  this(ManageAppConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/configurations", &handleCreate);
    router.get("/api/v1/configurations", &handleList);
    router.get("/api/v1/configurations/*", &handleGet);
    router.put("/api/v1/configurations/*", &handleUpdate);
    router.delete_("/api/v1/configurations/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateAppConfigurationRequest r;
      r.tenantId = tenantId;
      r.appId = j.getString("appId");
      r.key = j.getString("key");
      r.value = j.getString("value");
      r.description = j.getString("description");
      r.isSecret = j.getBoolean("isSecret");
      r.platform = j.getString("platform");
      r.createdBy = UserId(j.getString("createdBy"));
      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("key", item.key)
          .set("platform", item.platform)
          .set("status", item.status);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", results.length)
        .set("message", "App configurations retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = usecase.get(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("key", result.data.key)
          .set("value", result.data.value)
          .set("description", result.data.description)
          .set("isSecret", result.data.isSecret)
          .set("platform", result.data.platform)
          .set("createdBy", result.data.createdBy)
          .set("message", "App configuration retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateAppConfigurationRequest r;
      r.id = id;
      r.value = j.getString("value");
      r.description = j.getString("description");
      r.isSecret = j.getBoolean("isSecret");
      r.platform = j.getString("platform");
      r.updatedBy = UserId(j.getString("updatedBy"));
      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = AppConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteAppConfiguration(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "App configuration deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
