/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.audit_config;
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
    router.get("/api/v1/configs/*", &handleGet);
    router.put("/api/v1/configs/*", &handleUpdate);
    router.delete_("/api/v1/configs/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    
    auto configs = useCase.listAuditConfigs(tenantId);
    auto arr = configs.map!(c => c.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", configs.length)
      .set("message", "Audit configs retrieved successfully");
  }

  override Json createHandler(HTTPServerRequest req) {
    auto request = CreateAuditConfigRequest();
    request.tenantId = TenantId(req.json.getString("tenantId"));
    request.name = req.json.getString("name");
    request.logDataAccess = req.json.getBoolean("logDataAccess", true);
    request.logDataModification = req.json.getBoolean("logDataModification", true);
    request.logSecurityEvents = req.json.getBoolean("logSecurityEvents", true);
    request.logConfigurationChanges = req.json.getBoolean("logConfigurationChanges", true);
    request.enableDataMasking = req.json.getBoolean("enableDataMasking");
    request.maskedFields = getStrings(req.json, "maskedFields");
    request.excludedServices = getStrings(req.json, "excludedServices");

    auto sevStr = req.json.getString("minimumSeverity");
    if (sevStr == "warning")
      request.minimumSeverity = AuditSeverity.warning;
    else if (sevStr == "error")
      request.minimumSeverity = AuditSeverity.error;
    else if (sevStr == "critical")
      request.minimumSeverity = AuditSeverity.critical;
    else
      request.minimumSeverity = AuditSeverity.info;

    request.rateLimitPerSecond = req.json.getInteger("rateLimitPerSecond", 8);

    auto result = useCase.createAuditConfig(request);
    if (result.hasError)
            return errorResponse(result.message, 400);
      auto response = Json.emptyObject
        .set("id", result.id)
        .set("message", "Audit config created successfully")
        .set("statusCode", 201);

      return response;
    } else {
      return Json.emptyObject
        .set("error", "Failed to create audit config")
        .set("statusCode", 400);
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;

    auto cfg = useCase.getAuditConfig(tenantId);
    if (cfg.isNull) {
      return Json.emptyObject
        .set("error", "Audit config not found")
        .set("statusCode", 404);
    }
    return cfg.toJson
      .set("statusCode", 200)
      .set("message", "Audit config retrieved successfully");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;

    auto j = req.json;
    auto r = UpdateAuditConfigRequest();
    r.id = AuditConfigId(precheck.id);
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
    if (result.hasError()) {
      return Json.emptyObject
        .set("error", result.message)
        .set("statusCode", 400);
    }
    return Json.emptyObject
      .set("status", "updated")
      .set("message", "Audit config updated successfully")
      .set("statusCode", 200);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
      auto tenantId = req.getTenantId;
      auto id = AuditConfigId(precheck.id);

      useCase.deleteAuditConfig(tenantId, id);
      return Json.emptyObject
        .set("status", "deleted")
        .set("statusCode", 200)
        .set("message", "Audit config deleted successfully");
  }
}
