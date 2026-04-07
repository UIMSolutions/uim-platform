/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.module_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.kyma.application.usecases.manage.modules;
import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.kyma_module;
import uim.platform.kyma.domain.types;
import uim.platform.kyma.presentation.http.json_utils;

class ModuleController {
  private ManageModulesUseCase uc;

  this(ManageModulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/modules", &handleEnable);
    router.get("/api/v1/modules", &handleList);
    router.get("/api/v1/modules/*", &handleGetById);
    router.put("/api/v1/modules/*", &handleUpdate);
    router.post("/api/v1/modules/disable/*", &handleDisable);
    router.delete_("/api/v1/modules/*", &handleDelete);
  }

  private void handleEnable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      EnableModuleRequest r;
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.moduleType = j.getString("moduleType");
      r.version_ = j.getString("version");
      r.channel = j.getString("channel");
      r.customResourcePolicy = j.getString("customResourcePolicy");
      r.configurationJson = j.getString("configuration");
      r.enabledBy = req.headers.get("X-User-Id", "");

      auto result = uc.enableModule(r);
      if (result.success)
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto envIdParam = req.params.get("environmentId");
      string envId = envIdParam.length > 0 ? envIdParam : req.headers.get("X-Environment-Id", "");

      auto items = uc.listByEnvironment(envId);
      auto arr = Json.emptyArray;
      foreach (ref m; items)
        arr ~= serializeModule(m);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto m = uc.getModule(id);
      if (m.id.length == 0)
      {
        writeError(res, 404, "Module not found");
        return;
      }
      res.writeJsonBody(serializeModule(m), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateModuleRequest r;
      r.version_ = j.getString("version");
      r.channel = j.getString("channel");
      r.customResourcePolicy = j.getString("customResourcePolicy");
      r.configurationJson = j.getString("configuration");

      auto result = uc.updateModule(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDisable(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.disableModule(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteModule(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeModule(ref KymaModule m) {
    auto j = Json.emptyObject;
    j["id"] = Json(m.id);
    j["environmentId"] = Json(m.environmentId);
    j["tenantId"] = Json(m.tenantId);
    j["name"] = Json(m.name);
    j["description"] = Json(m.description);
    j["moduleType"] = Json(m.moduleType.to!string);
    j["status"] = Json(m.status.to!string);
    j["version"] = Json(m.version_);
    j["channel"] = Json(m.channel);
    j["customResourcePolicy"] = Json(m.customResourcePolicy);
    j["configuration"] = Json(m.configurationJson);
    j["requiredModules"] = serializeStrArray(m.requiredModules);
    j["enabledBy"] = Json(m.enabledBy);
    j["enabledAt"] = Json(m.enabledAt);
    j["modifiedAt"] = Json(m.modifiedAt);
    return j;
  }
}
