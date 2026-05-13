/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.audit_config;



// import vibe.data.json;
// 
// 
// import uim.platform.auditlog.application.usecases.manage.audit_config;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class AuditConfigController : ManageController {
  private ManageAuditConfigUseCase useCase;

  this(ManageAuditConfigUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/configs", &handleCreate);
    router.get("/api/v1/configs", &handleList);
    router.get("/api/v1/configs/*", &handleGetByTenant);
    router.put("/api/v1/configs/*", &handleUpdate);
    router.delete_("/api/v1/configs/*", &handleDelete);
  }

  override Json createHandler(Json data) {
    auto request = CreateAuditConfigRequest();
    request.tenantId = TenantId(data.getString("tenantId"));
    request.name = data.getString("name");
    request.logDataAccess = data.getBoolean("logDataAccess", true);
    request.logDataModification = data.getBoolean("logDataModification", true);
    request.logSecurityEvents = data.getBoolean("logSecurityEvents", true);
    request.logConfigurationChanges = data.getBoolean("logConfigurationChanges", true);
    request.enableDataMasking = data.getBoolean("enableDataMasking");
    request.maskedFields = getStrings(data, "maskedFields");
    request.excludedServices = getStrings(data, "excludedServices");

    auto sevStr = data.getString("minimumSeverity");
    if (sevStr == "warning")
      request.minimumSeverity = AuditSeverity.warning;
    else if (sevStr == "error")
      request.minimumSeverity = AuditSeverity.error;
    else if (sevStr == "critical")
      request.minimumSeverity = AuditSeverity.critical;
    else
      request.minimumSeverity = AuditSeverity.info;

    request.rateLimitPerSecond = data.getInteger("rateLimitPerSecond", 8);

    auto result = useCase.createAuditConfig(request);
    if (result.isSuccess()) {
      auto response = Json.emptyObject
        .set("id", result.id)
        .set("message", "Audit config created successfully")
        .set("status", 201);

      return response;
    } else {
      return Json.emptyObject
        .set("error", "Failed to create audit config")
        .set("status", 400);
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto configs = useCase.listAuditConfigs();
      auto arr = configs.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", configs.length)
        .set("message", "Audit configs retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetGetByTenant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      if (!useCase.existsAuditConfig(tenantId)) {
        writeError(res, 404, "Audit config not found");
        return;
      }
      auto cfg = useCase.getAuditConfig(tenantId);
      res.writeJsonBody(cfg.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      auto r = UpdateAuditConfigRequest();
      r.id = AuditConfigId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.logDataAccess = j.getBoolean("logDataAccess", true);
      r.logDataModification = j.getBoolean("logDataModification", true);
      r.logSecurityEvents = j.getBoolean("logSecurityEvents", true);
      r.logConfigurationChanges = j.getBoolean("logConfigurationChanges", true);
      r.enableDataMasking = j.getBoolean("enableDataMasking");
      r.maskedFields = getStrings(j, "maskedFields");
      r.excludedServices = getStrings(j, "excludedServices");
      r.rateLimitPerSecond = j.getInteger("rateLimitPerSecond", 8);

      r.status = j.getString("status") == "disabled" ? ConfigStatus.disabled : ConfigStatus.enabled;

      auto sevStr = j.getString("minimumSeverity");
      if (sevStr == "warning")
        r.minimumSeverity = AuditSeverity.warning;
      else if (sevStr == "error")
        r.minimumSeverity = AuditSeverity.error;
      else if (sevStr == "critical")
        r.minimumSeverity = AuditSeverity.critical;
      else
        r.minimumSeverity = AuditSeverity.info;

      auto result = useCase.updateAuditConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Audit config updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto id = AuditConfigId(extractIdFromPath(req.requestURI));
      useCase.deleteAuditConfig(tenantId, id);
      auto resp = Json.emptyObject
        .set("status", "deleted")
        .set("message", "Audit config deleted successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeConfig(const AuditConfig c) {
    auto json = Json.emptyObject
      .set("id", c.id.toJson)
      .set("tenantId", c.tenantId.toJson)
      .set("name", c.name.toJson)
      .set("status", c.status.to!string.toJson)
      .set("logDataAccess", c.logDataAccess.toJson)
      .set("logDataModification", c.logDataModification.toJson)
      .set("logSecurityEvents", c.logSecurityEvents.toJson)
      .set("logConfigurationChanges", c.logConfigurationChanges.toJson)
      .set("enableDataMasking", c.enableDataMasking.toJson)
      .set("minimumSeverity", c.minimumSeverity.to!string.toJson)
      .set("rateLimitPerSecond", c.rateLimitPerSecond.toJson)
      .set("createdAt", c.createdAt.toJson)
      .set("updatedAt", c.updatedAt.toJson);

    if (c.maskedFields.length > 0) {
      json["maskedFields"] = c.maskedFields.map!(f => Json(f)).array.toJson;
    }
    if (c.excludedServices.length > 0) {
      json["excludedServices"] = c.excludedServices.map!(s => Json(s)).array.toJson;
    }
    return json;
  }
}
