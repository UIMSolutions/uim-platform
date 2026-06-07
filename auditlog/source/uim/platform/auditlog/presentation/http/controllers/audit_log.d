/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.audit_log;

// 
// 
// import uim.platform.auditlog.application.usecases.write.audit_log;
// import uim.platform.auditlog.application.usecases.retrieve_audit_logs;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;

import uim.platform.auditlog;

// mixin(ShowModule!());
@safe:
class AuditLogController : HttpController {
  private WriteAuditLogUseCase writeUsecase;
  private RetrieveAuditLogsUseCase retrieveUsecase;

  this(WriteAuditLogUseCase writeUsecase, RetrieveAuditLogsUseCase retrieveUsecase) {
    this.writeUsecase = writeUsecase;
    this.retrieveUsecase = retrieveUsecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/auditlog", &handleWrite);
    router.get("/api/v1/auditlog", &handleQuery);
    router.get("/api/v1/auditlog/*", &handleGet);
  }

  protected Json writeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = WriteAuditLogRequest();
    r.tenantId = tenantId;
    r.userId = data.getString("userId");
    r.userName = data.getString("userName");
    r.serviceId = data.getString("serviceId");
    r.serviceName = data.getString("serviceName");
    r.category = data.getString("category").to!AuditCategory;
    r.severity = data.getString("severity").to!AuditSeverity;
    r.action = data.getString("action").to!AuditAction;
    r.outcome = data.getString("outcome").to!AuditOutcome;
    r.objectType = data.getString("objectType");
    r.objectId = data.getString("objectId");
    r.message = data.getString("message");
    r.attributes = parseAttributes(data);
    r.ipAddress = data.getString("ipAddress");
    r.userAgent = data.getString("userAgent");
    r.correlationId = data.getString("correlationId");
    r.originApp = data.getString("originApp");

    auto result = writeUsecase.writeAuditLog(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Audit log entry created successfully", 201,
      Json.emptyObject.set("id", result.id));
    }

  protected void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = writeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json queryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto queryReq = AuditLogQueryRequest();
    queryReq.tenantId = tenantId;

    // Parse category filter (comma-separated)
    auto catParam = req.headers.get("X-Category-Filter", "");
    if (catParam.length > 0) {
      // import std.string : split;

      foreach (c; catParam.split(","))
        queryReq.categories ~= toAuditCategory(c);
    }

    queryReq.timeFrom = jsonLong(Json.emptyObject, "unused"); // default 0
    queryReq.timeTo = 0;
    queryReq.limit = 500;
    queryReq.offset = 0;

    auto entries = retrieveUsecase.queryAuditLogs(queryReq);
    auto arr = entries.map!(e => e.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(entries.length));
    return successResponse("Audit log entries retrieved successfully", 200, responseData);
  }

  protected void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = queryHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AuditLogId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid audit log ID", 400);

    auto entry = retrieveUsecase.getAuditLog(tenantId, id);
    if (entry.isNull)
      return errorResponse("Audit log entry not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Audit log entry retrieved successfully", "Retrieved", 200, responseData);
  }

  private static AuditAttribute[] parseAttributes(Json data) {
    AuditAttribute[] result;
    foreach (item; data.getArray("attributes")) {
      if (item.isObject) {
        result ~= AuditAttribute(item.getString("name"),
          item.getString("oldValue"), item.getString("newValue"));
      }
    }
    return result;
  }
}
