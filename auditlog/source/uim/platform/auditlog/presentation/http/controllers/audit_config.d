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
class AuditConfigController : SAPController {
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
      request.tenantId = req.headers.get("X-Tenant-Id", "");
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto configs = useCase.listConfigs();
      auto arr = Json.emptyArray;
      foreach (ref c; configs)
        arr ~= serializeConfig(c);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = configs.length;
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetByTenant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto cfg = useCase.getConfig(tenantId);
      if (cfg is null) {
        writeError(res, 404, "Audit config not found");
        return;
      }
      res.writeJsonBody(serializeConfig(cfg), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateAuditConfigRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      useCase.deleteConfig(id, tenantId);
      auto resp = Json.emptyObject;
      resp["status"] = Json("deleted");
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeConfig(ref const AuditConfig c) {
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["name"] = Json(c.name);
    j["status"] = Json(c.status.to!string);
    j["logDataAccess"] = Json(c.logDataAccess);
    j["logDataModification"] = Json(c.logDataModification);
    j["logSecurityEvents"] = Json(c.logSecurityEvents);
    j["logConfigurationChanges"] = Json(c.logConfigurationChanges);
    j["enableDataMasking"] = Json(c.enableDataMasking);
    j["minimumSeverity"] = Json(c.minimumSeverity.to!string);
    j["rateLimitPerSecond"] = Json(cast(long) c.rateLimitPerSecond);
    j["createdAt"] = Json(c.createdAt);
    j["updatedAt"] = Json(c.updatedAt);

    if (c.maskedFields.length > 0) {
      auto mf = Json.emptyArray;
      foreach (ref f; c.maskedFields)
        mf ~= Json(f);
      j["maskedFields"] = mf;
    }
    if (c.excludedServices.length > 0) {
      auto es = Json.emptyArray;
      foreach (ref s; c.excludedServices)
        es ~= Json(s);
      j["excludedServices"] = es;
    }
    return j;
  }
}
