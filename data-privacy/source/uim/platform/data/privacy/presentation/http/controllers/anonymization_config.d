/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.anonymization_config;

// import uim.platform.data.privacy.application.usecases.manage.anonymization_configs;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.anonymization_config;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class AnonymizationConfigController : PlatformController {
  private ManageAnonymizationConfigsUseCase uc;

  this(ManageAnonymizationConfigsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/anonymization-configs", &handleCreate);
    router.get("/api/v1/anonymization-configs", &handleList);
    router.get("/api/v1/anonymization-configs/*", &handleGetById);
    router.put("/api/v1/anonymization-configs/*", &handleUpdate);
    router.post("/api/v1/anonymization-configs/*/activate", &handleActivate);
    router.delete_("/api/v1/anonymization-configs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAnonymizationConfigRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isReversible = j.getBoolean("isReversible", false);
      r.targetSystems = getStringArray(j, "targetSystems");

      auto result = uc.createConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listConfigs(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getConfig(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Anonymization config not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateAnonymizationConfigRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isReversible = j.getBoolean("isReversible", false);
      r.targetSystems = getStringArray(j, "targetSystems");

      auto result = uc.updateConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      auto result = uc.activateConfig(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteConfig(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const AnonymizationConfig e) {
    auto j = Json.emptyObject
      .set("id", Json(e.id))
      .set("tenantId", Json(e.tenantId))
      .set("name", Json(e.name))
      .set("description", Json(e.description))
      .set("status", Json(e.status.to!string))
      .set("isReversible", Json(e.isReversible))
      .set("createdAt", Json(e.createdAt))
      .set("updatedAt", Json(e.updatedAt));

    auto systems = Json.emptyArray;
    foreach (s; e.targetSystems)
      systems ~= Json(s);
    j["targetSystems"] = systems;

    return j;
  }
}
