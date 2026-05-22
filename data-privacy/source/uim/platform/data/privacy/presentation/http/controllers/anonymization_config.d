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
  private ManageAnonymizationConfigsUseCase usecase;

  this(ManageAnonymizationConfigsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/anonymization-configs", &handleCreate);
    router.get("/api/v1/anonymization-configs", &handleList);
    router.get("/api/v1/anonymization-configs/*", &handleGet);
    router.put("/api/v1/anonymization-configs/*", &handleUpdate);
    router.post("/api/v1/anonymization-configs/*/activate", &handleActivate);
    router.delete_("/api/v1/anonymization-configs/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateAnonymizationConfigRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isReversible = j.getBoolean("isReversible", false);
      r.targetSystems = getStrings(j, "targetSystems");

      auto result = usecase.createConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Anonymization config created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto items = usecase.listConfigs(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Anonymization configs retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AnonymizationConfigId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getConfig(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Anonymization config not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateAnonymizationConfigRequest r;
      r.id = AnonymizationConfigId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isReversible = j.getBoolean("isReversible", false);
      r.targetSystems = getArray(j, "targetSystems").map!(c => c.to!string).array;

      auto result = usecase.updateConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id);
            
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AnonymizationConfigId(extractIdFromPath(req.requestURI));

      auto result = usecase.activateConfig(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AnonymizationConfigId(extractIdFromPath(req.requestURI));

      usecase.deleteConfig(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

}
