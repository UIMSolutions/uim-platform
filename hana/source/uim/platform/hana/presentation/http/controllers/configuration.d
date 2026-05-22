/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.configuration;
// import uim.platform.hana.application.usecases.manage.configurations;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ConfigurationController : PlatformController {
  private ManageConfigurationsUseCase usecase;

  this(ManageConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/configurations", &handleList);
    router.get("/api/v1/hana/configurations/*", &handleGet);
    router.post("/api/v1/hana/configurations", &handleCreate);
    router.put("/api/v1/hana/configurations/*", &handleUpdate);
    router.delete_("/api/v1/hana/configurations/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateConfigurationRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.section = j.getString("section");
      r.key = j.getString("key");
      r.value = j.getString("value");
      r.scope_ = j.getString("scope");
      r.dataType = j.getString("dataType");
      r.description = j.getString("description");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Configuration created");
        
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto configs = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; configs) {
        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("instanceId", c.instanceId)
          .set("section", c.section)
          .set("key", c.key)
          .set("value", c.value)
          .set("isReadOnly", c.isReadOnly)
          .set("requiresRestart", c.requiresRestart);
      }

      auto resp = Json.emptyObject
        .set("count", configs.length)
        .set("resources", jarr);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto c = usecase.getById(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("section", c.section)
        .set("key", c.key)
        .set("value", c.value)
        .set("defaultValue", c.defaultValue)
        .set("description", c.description)
        .set("isReadOnly", c.isReadOnly)
        .set("requiresRestart", c.requiresRestart)
        .set("updatedAt", c.updatedAt)
        .set("updatedBy", c.updatedBy);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateConfigurationRequest r;
      r.tenantId = tenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.value = j.getString("value");

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Configuration updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteConfiguration(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
