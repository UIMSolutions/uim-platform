module uim.platform.auditlog.presentation.http.controllers.audit_log;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.auditlog.application.usecases.write_audit_log;
import uim.platform.auditlog.application.usecases.retrieve_audit_logs;
import uim.platform.auditlog.application.dto;
import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_log_entry;
import uim.platform.identity_authentication.presentation.http.json_utils;

class AuditLogController
{
    private WriteAuditLogUseCase writeUC;
    private RetrieveAuditLogsUseCase retrieveUC;

    this(WriteAuditLogUseCase writeUC, RetrieveAuditLogsUseCase retrieveUC)
    {
        this.writeUC = writeUC;
        this.retrieveUC = retrieveUC;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/auditlog", &handleWrite);
        router.get("/api/v1/auditlog", &handleQuery);
        router.get("/api/v1/auditlog/*", &handleGetById);
    }

    private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = WriteAuditLogRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.userId = jsonStr(j, "userId");
            r.userName = jsonStr(j, "userName");
            r.serviceId = jsonStr(j, "serviceId");
            r.serviceName = jsonStr(j, "serviceName");
            r.category = parseCategory(jsonStr(j, "category"));
            r.severity = parseSeverity(jsonStr(j, "severity"));
            r.action = parseAction(jsonStr(j, "action"));
            r.outcome = parseOutcome(jsonStr(j, "outcome"));
            r.objectType = jsonStr(j, "objectType");
            r.objectId = jsonStr(j, "objectId");
            r.message = jsonStr(j, "message");
            r.attributes = parseAttributes(j);
            r.ipAddress = jsonStr(j, "ipAddress");
            r.userAgent = jsonStr(j, "userAgent");
            r.correlationId = jsonStr(j, "correlationId");
            r.originApp = jsonStr(j, "originApp");

            auto result = writeUC.writeLog(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto queryReq = AuditLogQueryRequest();
            queryReq.tenantId = tenantId;

            // Parse category filter (comma-separated)
            auto catParam = req.headers.get("X-Category-Filter", "");
            if (catParam.length > 0)
            {
                import std.string : split;
                foreach (c; catParam.split(","))
                    queryReq.categories ~= parseCategory(c);
            }

            queryReq.timeFrom = jsonLong(Json.emptyObject, "unused"); // default 0
            queryReq.timeTo = 0;
            queryReq.limit = 500;
            queryReq.offset = 0;

            auto entries = retrieveUC.query(queryReq);
            auto arr = Json.emptyArray;
            foreach (ref e; entries)
                arr ~= serializeEntry(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) entries.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto entry = retrieveUC.getById(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Audit log entry not found");
                return;
            }
            res.writeJsonBody(serializeEntry(*entry), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeEntry(ref const AuditLogEntry e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["userId"] = Json(e.userId);
        j["userName"] = Json(e.userName);
        j["serviceId"] = Json(e.serviceId);
        j["serviceName"] = Json(e.serviceName);
        j["category"] = Json(categoryToString(e.category));
        j["severity"] = Json(e.severity.to!string);
        j["action"] = Json(e.action.to!string);
        j["outcome"] = Json(e.outcome.to!string);
        j["objectType"] = Json(e.objectType);
        j["objectId"] = Json(e.objectId);
        j["message"] = Json(e.message);
        j["ipAddress"] = Json(e.ipAddress);
        j["userAgent"] = Json(e.userAgent);
        j["correlationId"] = Json(e.correlationId);
        j["originApp"] = Json(e.originApp);
        j["timestamp"] = Json(e.timestamp);
        j["formatVersion"] = Json(e.formatVersion);

        if (e.attributes.length > 0)
        {
            auto attrs = Json.emptyArray;
            foreach (ref a; e.attributes)
            {
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

    private static AuditAttribute[] parseAttributes(Json j)
    {
        AuditAttribute[] result;
        auto v = "attributes" in j;
        if (v is null || (*v).type != Json.Type.array)
            return result;
        foreach (item; *v)
        {
            if (item.type == Json.Type.object)
            {
                result ~= AuditAttribute(
                    jsonStr(item, "name"),
                    jsonStr(item, "oldValue"),
                    jsonStr(item, "newValue")
                );
            }
        }
        return result;
    }

    private static AuditCategory parseCategory(string s)
    {
        switch (s)
        {
            case "audit.security-events", "securityEvents": return AuditCategory.securityEvents;
            case "audit.configuration", "configuration":    return AuditCategory.configuration;
            case "audit.data-access", "dataAccess":         return AuditCategory.dataAccess;
            case "audit.data-modification", "dataModification": return AuditCategory.dataModification;
            default: return AuditCategory.securityEvents;
        }
    }

    private static string categoryToString(AuditCategory c)
    {
        final switch (c)
        {
            case AuditCategory.securityEvents:    return "audit.security-events";
            case AuditCategory.configuration:     return "audit.configuration";
            case AuditCategory.dataAccess:        return "audit.data-access";
            case AuditCategory.dataModification:  return "audit.data-modification";
        }
    }

    private static AuditSeverity parseSeverity(string s)
    {
        switch (s)
        {
            case "warning":  return AuditSeverity.warning;
            case "error":    return AuditSeverity.error;
            case "critical": return AuditSeverity.critical;
            default:         return AuditSeverity.info;
        }
    }

    private static AuditAction parseAction(string s)
    {
        switch (s)
        {
            case "create":         return AuditAction.create;
            case "read":           return AuditAction.read_;
            case "update":         return AuditAction.update;
            case "delete":         return AuditAction.delete_;
            case "login":          return AuditAction.login;
            case "logout":         return AuditAction.logout;
            case "loginFailed":    return AuditAction.loginFailed;
            case "passwordChange": return AuditAction.passwordChange;
            case "roleAssign":     return AuditAction.roleAssign;
            case "roleRevoke":     return AuditAction.roleRevoke;
            case "policyChange":   return AuditAction.policyChange;
            case "configChange":   return AuditAction.configChange;
            case "export":         return AuditAction.export_;
            case "dataAccess":     return AuditAction.dataAccess;
            case "consentChange":  return AuditAction.consentChange;
            case "tokenIssue":     return AuditAction.tokenIssue;
            case "tokenRevoke":    return AuditAction.tokenRevoke;
            case "mfaEnroll":      return AuditAction.mfaEnroll;
            case "mfaVerify":      return AuditAction.mfaVerify;
            default:               return AuditAction.create;
        }
    }

    private static AuditOutcome parseOutcome(string s)
    {
        switch (s)
        {
            case "failure": return AuditOutcome.failure;
            case "denied":  return AuditOutcome.denied;
            case "error":   return AuditOutcome.error;
            default:        return AuditOutcome.success;
        }
    }
}
