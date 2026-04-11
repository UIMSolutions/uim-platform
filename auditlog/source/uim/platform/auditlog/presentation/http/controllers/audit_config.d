/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.audit_config;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.manage.audit_config;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_config;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class AuditConfigController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto request = CreateAuditConfigRequest();
      request.tenantId = req.getTenantId;
      request.name = j.getString("name");
      request.logDataAccess = j.getBoolean("logDataAccess", true);
      request.logDataModification = j.getBoolean("logDataModification", true);
      request.logSecurityEvents = j.getBoolean("logSecurityEvents", true);
      request.logConfigurationChanges = j.getBoolean("logConfigurationChanges", true);
      request.enableDataMasking = j.getBoolean("enableDataMasking");
      request.maskedFields = jsonStrArray(j, "maskedFields");
      request.excludedServices = jsonStrArray(j, "excludedServices");

      auto sevStr = j.getString("minimumSeverity");
      if (sevStr == "warning")
        request.minimumSeverity = AuditSeverity.warning;
      else if (sevStr == "error")
        request.minimumSeverity = AuditSeverity.error;
      else if (sevStr == "critical")
        request.minimumSeverity = AuditSeverity.critical;
      else
        request.minimumSeverity = AuditSeverity.info;

      request.rateLimitPerSecond = j.getInteger("rateLimitPerSecond", 8);

      auto result = useCase.createConfig(request);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id));
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
      auto configs = useCase.listConfigs();
      auto arr = configs.map!(c => serializeConfig(c)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", configs.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetByTenant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      if (!useCase.existsConfig(tenantId)) {
        writeError(res, 404, "Audit config not found");
        return;
      }
      auto cfg = useCase.getConfig(tenantId);
      res.writeJsonBody(serializeConfig(cfg), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateAuditConfigRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.logDataAccess = j.getBoolean("logDataAccess", true);
      r.logDataModification = j.getBoolean("logDataModification", true);
      r.logSecurityEvents = j.getBoolean("logSecurityEvents", true);
      r.logConfigurationChanges = j.getBoolean("logConfigurationChanges", true);
      r.enableDataMasking = j.getBoolean("enableDataMasking");
      r.maskedFields = jsonStrArray(j, "maskedFields");
      r.excludedServices = jsonStrArray(j, "excludedServices");
      r.rateLimitPerSecond = j.getInteger("rateLimitPerSecond", 8);

      auto statusStr = j.getString("status");
      if (statusStr == "disabled")
        r.status = ConfigStatus.disabled;
      else
        r.status = ConfigStatus.enabled;

      auto sevStr = j.getString("minimumSeverity");
      if (sevStr == "warning")
        r.minimumSeverity = AuditSeverity.warning;
      else if (sevStr == "error")
        r.minimumSeverity = AuditSeverity.error;
      else if (sevStr == "critical")
        r.minimumSeverity = AuditSeverity.critical;
      else
        r.minimumSeverity = AuditSeverity.info;

      auto result = useCase.updateConfig(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
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
      auto id = AuditConfigId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      useCase.deleteConfig(tenantId, id);
      auto resp = Json.emptyObject
        .set("status", "deleted");
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
