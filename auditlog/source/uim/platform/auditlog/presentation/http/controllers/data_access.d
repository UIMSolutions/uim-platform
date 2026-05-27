/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.data_access;

// import uim.platform.auditlog.application.usecases.write.data_access_log;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class DataAccessController : PlatformController {
  private WriteDataAccessLogUseCase useCase;

  this(WriteDataAccessLogUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-access", &handleWrite);
  }

  protected void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = WriteDataAccessLogRequest();
      r.tenantId = tenantId;
      r.accessedBy = data.getString("accessedBy");
      r.dataSubject = data.getString("dataSubject");
      r.dataObjectType = data.getString("dataObjectType");
      r.dataObjectId = data.getString("dataObjectId");
      r.accessedFields = getStrings(j, "accessedFields");
      r.purpose = data.getString("purpose");
      r.channel = data.getString("channel");

      auto result = useCase.writeLog(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id);
            
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
