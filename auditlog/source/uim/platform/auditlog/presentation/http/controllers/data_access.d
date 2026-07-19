/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.data_access;

// import uim.platform.auditlog.application.usecases.write.data_access_log;
import uim.platform.auditlog;
mixin(ShowModule!());

@safe:
class DataAccessController : HttpController {
  private WriteDataAccessLogUseCase useCase;

  this(WriteDataAccessLogUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-access", &handleWrite);
  }

  protected Json writeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = WriteDataAccessLogRequest();
    r.tenantId = tenantId;
    r.accessedBy = data.getString("accessedBy");
    r.dataSubject = data.getString("dataSubject");
    r.dataObjectType = data.getString("dataObjectType");
    r.dataObjectId = data.getString("dataObjectId");
    r.accessedFields = data.getStrings("accessedFields");
    r.purpose = data.getString("purpose");
    r.channel = data.getString("channel");

    auto result = useCase.writeLog(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data access log written successfully", 201, responseData);
  }

  mixin(HandleTemplate!("handleWrite", "writeHandler"));

}
