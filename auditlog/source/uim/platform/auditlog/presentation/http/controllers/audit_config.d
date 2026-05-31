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
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

    auto configs = useCase.listAuditConfigs(tenantId);
    auto list = configs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Audit config list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto request = CreateAuditConfigRequest();
    request.tenantId = tenantId;
    request.name = data.getString("name");
    request.logDataAccess = data.getBoolean("logDataAccess", true);
    request.logDataModification = data.getBoolean("logDataModification", true);
    request.logSecurityEvents = data.getBoolean("logSecurityEvents", true);
    request.logConfigurationChanges = data.getBoolean("logConfigurationChanges", true);
    request.enableDataMasking = data.getBoolean("enableDataMasking");
    request.maskedFields = data.getStrings("maskedFields");
    request.excludedServices = data.getStrings("excludedServices");

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
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Audit config created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

    auto cfg = useCase.getAuditConfig(tenantId);
    if (cfg.isNull)
      return errorResponse("Audit config not found", 404);

    auto responseData = cfg.toJson();
    return successResponse("Audit config retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = UpdateAuditConfigRequest();
    r.id = AuditConfigId(precheck.id);
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.logDataAccess = data.getBoolean("logDataAccess", true);
    r.logDataModification = data.getBoolean("logDataModification", true);
    r.logSecurityEvents = data.getBoolean("logSecurityEvents", true);
    r.logConfigurationChanges = data.getBoolean("logConfigurationChanges", true);
    r.enableDataMasking = data.getBoolean("enableDataMasking");
    r.maskedFields = data.getStrings("maskedFields");
    r.excludedServices = data.getStrings("excludedServices");
    r.rateLimitPerSecond = data.getInteger("rateLimitPerSecond", 8);

    r.status = data.getString("status") == "disabled" ? ConfigStatus.disabled : ConfigStatus
      .enabled;

    auto sevStr = data.getString("minimumSeverity");
    if (sevStr == "warning")
      r.minimumSeverity = AuditSeverity.warning;
    else if (sevStr == "error")
      r.minimumSeverity = AuditSeverity.error;
    else if (sevStr == "critical")
      r.minimumSeverity = AuditSeverity.critical;
    else
      r.minimumSeverity = AuditSeverity.info;

    auto result = useCase.updateAuditConfig(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Audit config updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AuditConfigId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid audit config ID", 400);

    auto result = useCase.deleteAuditConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Audit config deleted successfully", 200, responseData);
  }
}
