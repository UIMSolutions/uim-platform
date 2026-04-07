/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.config_change;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;

// import uim.platform.auditlog.application.usecases.write.config_change;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;

import uim.platform.auditlog; 

mixin(ShowModule!());

@safe:
class ConfigChangeController : SAPController {
  private WriteConfigChangeUseCase useCase;

  this(WriteConfigChangeUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/config-changes", &handleWrite);
  }

  private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = WriteConfigChangeLogRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.changedBy = j.getString("changedBy");
      r.configType = j.getString("configType");
      r.configObjectId = j.getString("configObjectId");
      r.reason = j.getString("reason");
      r.changes = parseChanges(j);

      auto result = useCase.writeChange(r);
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

  private static AuditAttribute[] parseChanges(Json j) {
    AuditAttribute[] result;
    
    if (!("changes" in j) || !j["changes"].isArray)
      return result;

    foreach (item; j["changes"].toArray) {
      if (item.isObject) {
        result ~= AuditAttribute(
          item.getString("name"),
          item.getString("oldValue"), 
          item.getString("newValue"));
      }
    }
    return result;
  }
}
