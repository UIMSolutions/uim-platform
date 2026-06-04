/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.config_change;

// import uim.platform.auditlog.application.usecases.write.config_change;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class ConfigChangeController : HttpController {
  private WriteConfigChangeUseCase useCase;

  this(WriteConfigChangeUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/config-changes", &handleWrite);
  }

  protected Json writeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = WriteConfigChangeLogRequest();
    r.tenantId = precheck.tenantId;
    r.changedBy = data.getString("changedBy");
    r.configType = data.getString("configType");
    r.configObjectId = data.getString("configObjectId");
    r.reason = data.getString("reason");
    r.changes = parseChanges(data);
    
    auto result = useCase.writeChange(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Config change log entry created");

    return successResponse("Config change log entry created successfully", "Created", 201, resp);
  }

  protected void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = writeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static AuditAttribute[] parseChanges(Json j) {
    AuditAttribute[] result;

    // if (!j.isArray("changes"))
    //   return result;

    foreach (item; data.getArray("changes")) {
      if (item.isObject) {
        AuditAttribute change;
        change.name = item.getString("name");
        change.oldValue = item.getString("oldValue");
        change.newValue = item.getString("newValue");
        result ~= change;
      }
    }
    return result;
  }
}
