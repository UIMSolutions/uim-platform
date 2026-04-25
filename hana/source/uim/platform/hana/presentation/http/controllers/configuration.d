/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.configuration;

// import uim.platform.hana.application.usecases.manage.configurations;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ConfigurationController : PlatformController {
  private ManageConfigurationsUseCase uc;

  this(ManageConfigurationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/configurations", &handleList);
    router.get("/api/v1/hana/configurations/*", &handleGet);
    router.post("/api/v1/hana/configurations", &handleCreate);
    router.put("/api/v1/hana/configurations/*", &handleUpdate);
    router.delete_("/api/v1/hana/configurations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConfigurationRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.section = j.getString("section");
      r.key = j.getString("key");
      r.value = j.getString("value");
      r.scope_ = j.getString("scope");
      r.dataType = j.getString("dataType");
      r.description = j.getString("description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Configuration created");
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
      auto configs = uc.list(tenantId);

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

      auto resp = Json.emptyObject;
      resp["count"] = Json(configs.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto c = uc.getById(id);
      if (c.id.isEmpty) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(c.id);
      resp["instanceId"] = Json(c.instanceId);
      resp["section"] = Json(c.section);
      resp["key"] = Json(c.key);
      resp["value"] = Json(c.value);
      resp["defaultValue"] = Json(c.defaultValue);
      resp["description"] = Json(c.description);
      resp["isReadOnly"] = Json(c.isReadOnly);
      resp["requiresRestart"] = Json(c.requiresRestart);
      resp["updatedAt"] = Json(c.updatedAt);
      resp["modifiedBy"] = Json(c.modifiedBy);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateConfigurationRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.value = j.getString("value");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Configuration updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
