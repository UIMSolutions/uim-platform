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
    router.get("/api/v1/configs/*", &handleGetByTenant);
    router.put("/api/v1/configs/*", &handleUpdate);
    router.delete_("/api/v1/configs/*", &handleDelete);
  }

  override protected Json listHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto configs = useCase.listAuditConfigs();
    auto arr = configs.map!(c => c.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", configs.length)
      .set("message", "Audit configs retrieved successfully");
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

  override protected Json getHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;

    auto cfg = useCase.getAuditConfig(tenantId);
    if (cfg.isNull) {
      return Json.emptyObject
        .set("error", "Audit config not found")
        .set("status", 404);
    }
    return cfg.toJson
      .set("status", 200)
      .set("message", "Audit config retrieved successfully");
  }

  override protected Json updateHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
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
    if (result.isFailure()) {
      return Json.emptyObject
        .set("error", result.error)
        .set("status", 400);
    }
    return Json.emptyObject
      .set("status", "updated")
      .set("message", "Audit config updated successfully")
      .set("statusCode", 200);
  }

  override protected Json deleteHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      auto tenantId = req.getTenantId;
      auto id = AuditConfigId(extractIdFromPath(req.requestURI));

      useCase.deleteAuditConfig(tenantId, id);
      return Json.emptyObject
        .set("status", "deleted")
        .set("statusCode", 200)
        .set("message", "Audit config deleted successfully");
  }
}
