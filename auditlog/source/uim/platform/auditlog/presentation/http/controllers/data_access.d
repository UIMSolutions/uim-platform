/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.data_access;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.auditlog.application.usecases.write.data_access_log;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class DataAccessController : SAPController {
  private WriteDataAccessLogUseCase useCase;

  this(WriteDataAccessLogUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-access", &handleWrite);
  }

  private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = WriteDataAccessLogRequest();
      r.tenantId = req.getTenantId;
      r.accessedBy = j.getString("accessedBy");
      r.dataSubject = j.getString("dataSubject");
      r.dataObjectType = j.getString("dataObjectType");
      r.dataObjectId = j.getString("dataObjectId");
      r.accessedFields = jsonStrArray(j, "accessedFields");
      r.purpose = j.getString("purpose");
      r.channel = j.getString("channel");

      auto result = useCase.writeLog(r);
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
}
