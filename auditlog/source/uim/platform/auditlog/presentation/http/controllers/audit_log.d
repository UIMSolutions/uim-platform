/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.audit_log;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.write.audit_log;
// import uim.platform.auditlog.application.usecases.retrieve_audit_logs;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class AuditLogController : PlatformController {
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
    router.get("/api/v1/auditlog/*", &handleGetById);
  }

  private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = WriteAuditLogRequest();
      r.tenantId = req.getTenantId;
      r.userId = j.getString("userId");
      r.userName = j.getString("userName");
      r.serviceId = j.getString("serviceId");
      r.serviceName = j.getString("serviceName");
      r.category = parseCategory(j.getString("category"));
      r.severity = parseSeverity(j.getString("severity"));
      r.action = parseAction(j.getString("action"));
      r.outcome = parseOutcome(j.getString("outcome"));
      r.objectType = j.getString("objectType");
      r.objectId = j.getString("objectId");
      r.message = j.getString("message");
      r.attributes = parseAttributes(j);
      r.ipAddress = j.getString("ipAddress");
      r.userAgent = j.getString("userAgent");
      r.correlationId = j.getString("correlationId");
      r.originApp = j.getString("originApp");

      auto result = writeUsecase.writeLog(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto queryReq = AuditLogQueryRequest();
      queryReq.tenantId = tenantId;

      // Parse category filter (comma-separated)
      auto catParam = req.headers.get("X-Category-Filter", "");
      if (catParam.length > 0) {
        // import std.string : split;

        foreach (c; catParam.split(","))
          queryReq.categories ~= parseCategory(c);
      }

      queryReq.timeFrom = jsonLong(Json.emptyObject, "unused"); // default 0
      queryReq.timeTo = 0;
      queryReq.limit = 500;
      queryReq.offset = 0;

      auto entries = retrieveUsecase.query(queryReq);
      auto arr = entries.map!(e => serializeEntry(e)).array.toJson;

      auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(entries.length));
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      if (!retrieveUsecase.existsById(tenantId, AuditLogId(id))) {
        writeError(res, 404, "Audit log entry not found");
        return;
      }

      auto entry = retrieveUsecase.getById(tenantId, AuditLogId(id));
      res.writeJsonBody(serializeEntry(entry), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeEntry(const AuditLogEntry e) {
    auto j = Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("userId", e.userId)
      .set("userName", e.userName)
      .set("serviceId", e.serviceId)
      .set("serviceName", e.serviceName)
      .set("category", categoryToString(e.category))
      .set("severity", e.severity.to!string)
      .set("action", e.action.to!string)
      .set("outcome", e.outcome.to!string)
      .set("objectType", e.objectType)
      .set("objectId", e.objectId)
      .set("message", e.message)
      .set("ipAddress", e.ipAddress)
      .set("userAgent", e.userAgent)
      .set("correlationId", e.correlationId)
      .set("originApp", e.originApp)
      .set("timestamp", e.timestamp)
      .set("formatVersion", e.formatVersion);

    if (e.attributes.length > 0) {
      auto attrs = Json.emptyArray;
      foreach (a; e.attributes) {
        auto aj = Json.emptyObject;
        aj["name"] = Json(a.name);
        aj["oldValue"] = Json(a.oldValue);
        aj["newValue"] = Json(a.newValue);
        attrs ~= aj;
      }
      j["attributes"] = attrs;
    }
    return j;
  }

  private static AuditAttribute[] parseAttributes(Json j) {
    AuditAttribute[] result;

    if (j.hasKey("attributes")) {
      if (j.isNull)
        return null;
        
      if (j.type != Json.Type.array)
        return result;
    }

    foreach (item; j["attributes"].toArray) {
      if (item.isObject) {
        result ~= AuditAttribute(item.getString("name"),
          item.getString("oldValue"), item.getString("newValue"));
      }
    }
    return result;
  }

  private static AuditCategory parseCategory(string s) {
    switch (s) {
    case "audit.security-events", "securityEvents":
      return AuditCategory.securityEvents;
    case "audit.configuration", "configuration":
      return AuditCategory.configuration;
    case "audit.data-access", "dataAccess":
      return AuditCategory.dataAccess;
    case "audit.data-modification", "dataModification":
      return AuditCategory.dataModification;
    default:
      return AuditCategory.securityEvents;
    }
  }

  private static string categoryToString(AuditCategory c) {
    final switch (c) {
    case AuditCategory.securityEvents:
      return "audit.security-events";
    case AuditCategory.configuration:
      return "audit.configuration";
    case AuditCategory.dataAccess:
      return "audit.data-access";
    case AuditCategory.dataModification:
      return "audit.data-modification";
    }
  }

  private static AuditSeverity parseSeverity(string s) {
    switch (s) {
    case "warning":
      return AuditSeverity.warning;
    case "error":
      return AuditSeverity.error;
    case "critical":
      return AuditSeverity.critical;
    default:
      return AuditSeverity.info;
    }
  }

  private static AuditAction parseAction(string s) {
    switch (s) {
    case "create":
      return AuditAction.create;
    case "read":
      return AuditAction.read_;
    case "update":
      return AuditAction.update;
    case "delete":
      return AuditAction.delete_;
    case "login":
      return AuditAction.login;
    case "logout":
      return AuditAction.logout;
    case "loginFailed":
      return AuditAction.loginFailed;
    case "passwordChange":
      return AuditAction.passwordChange;
    case "roleAssign":
      return AuditAction.roleAssign;
    case "roleRevoke":
      return AuditAction.roleRevoke;
    case "policyChange":
      return AuditAction.policyChange;
    case "configChange":
      return AuditAction.configChange;
    case "export":
      return AuditAction.export_;
    case "dataAccess":
      return AuditAction.dataAccess;
    case "consentChange":
      return AuditAction.consentChange;
    case "tokenIssue":
      return AuditAction.tokenIssue;
    case "tokenRevoke":
      return AuditAction.tokenRevoke;
    case "mfaEnroll":
      return AuditAction.mfaEnroll;
    case "mfaVerify":
      return AuditAction.mfaVerify;
    default:
      return AuditAction.create;
    }
  }

  private static AuditOutcome parseOutcome(string s) {
    switch (s) {
    case "failure":
      return AuditOutcome.failure;
    case "denied":
      return AuditOutcome.denied;
    case "error":
      return AuditOutcome.error;
    default:
      return AuditOutcome.success;
    }
  }
}
