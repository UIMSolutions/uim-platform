module uim.platform.identity_authentication.presentation.http.audit_config_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_audit_config;
import application.dto;
import domain.types;
import domain.entities.audit_config;
import uim.platform.identity_authentication.presentation.http.json_utils;

class AuditConfigController {
    private ManageAuditConfigUseCase useCase;

    this(ManageAuditConfigUseCase useCase) {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router) {
        router.post("/api/v1/configs", &handleCreate);
        router.get("/api/v1/configs", &handleList);
        router.get("/api/v1/configs/*", &handleGetByTenant);
        router.put("/api/v1/configs/*", &handleUpdate);
        router.delete_("/api/v1/configs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = CreateAuditConfigRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.logDataAccess = jsonBool(j, "logDataAccess", true);
            r.logDataModification = jsonBool(j, "logDataModification", true);
            r.logSecurityEvents = jsonBool(j, "logSecurityEvents", true);
            r.logConfigurationChanges = jsonBool(j, "logConfigurationChanges", true);
            r.enableDataMasking = jsonBool(j, "enableDataMasking");
            r.maskedFields = jsonStrArray(j, "maskedFields");
            r.excludedServices = jsonStrArray(j, "excludedServices");

            auto sevStr = jsonStr(j, "minimumSeverity");
            if (sevStr == "warning")
                r.minimumSeverity = AuditSeverity.warning;
            else if (sevStr == "error")
                r.minimumSeverity = AuditSeverity.error;
            else if (sevStr == "critical")
                r.minimumSeverity = AuditSeverity.critical;
            else
                r.minimumSeverity = AuditSeverity.info;

            r.rateLimitPerSecond = jsonInt(j, "rateLimitPerSecond", 8);

            auto result = useCase.createConfig(r);
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto configs = useCase.listConfigs();
            auto arr = Json.emptyArray;
            foreach (ref c; configs)
                arr ~= serializeConfig(c);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)configs.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetByTenant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto cfg = useCase.getConfig(tenantId);
            if (cfg is null) {
                writeError(res, 404, "Audit config not found");
                return;
            }
            res.writeJsonBody(serializeConfig(*cfg), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = UpdateAuditConfigRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.logDataAccess = jsonBool(j, "logDataAccess", true);
            r.logDataModification = jsonBool(j, "logDataModification", true);
            r.logSecurityEvents = jsonBool(j, "logSecurityEvents", true);
            r.logConfigurationChanges = jsonBool(j, "logConfigurationChanges", true);
            r.enableDataMasking = jsonBool(j, "enableDataMasking");
            r.maskedFields = jsonStrArray(j, "maskedFields");
            r.excludedServices = jsonStrArray(j, "excludedServices");
            r.rateLimitPerSecond = jsonInt(j, "rateLimitPerSecond", 8);

            auto statusStr = jsonStr(j, "status");
            if (statusStr == "disabled")
                r.status = ConfigStatus.disabled;
            else
                r.status = ConfigStatus.enabled;

            auto sevStr = jsonStr(j, "minimumSeverity");
            if (sevStr == "warning")
                r.minimumSeverity = AuditSeverity.warning;
            else if (sevStr == "error")
                r.minimumSeverity = AuditSeverity.error;
            else if (sevStr == "critical")
                r.minimumSeverity = AuditSeverity.critical;
            else
                r.minimumSeverity = AuditSeverity.info;

            auto result = useCase.updateConfig(r);
            if (result.isSuccess()) {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deleteConfig(id, tenantId);
            auto resp = Json.emptyObject;
            resp["status"] = Json("deleted");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeConfig(ref const AuditConfig c) {
        auto j = Json.emptyObject;
        j["id"] = Json(c.id);
        j["tenantId"] = Json(c.tenantId);
        j["name"] = Json(c.name);
        j["status"] = Json(c.status.to!string);
        j["logDataAccess"] = Json(c.logDataAccess);
        j["logDataModification"] = Json(c.logDataModification);
        j["logSecurityEvents"] = Json(c.logSecurityEvents);
        j["logConfigurationChanges"] = Json(c.logConfigurationChanges);
        j["enableDataMasking"] = Json(c.enableDataMasking);
        j["minimumSeverity"] = Json(c.minimumSeverity.to!string);
        j["rateLimitPerSecond"] = Json(cast(long)c.rateLimitPerSecond);
        j["createdAt"] = Json(c.createdAt);
        j["updatedAt"] = Json(c.updatedAt);

        if (c.maskedFields.length > 0) {
            auto mf = Json.emptyArray;
            foreach (ref f; c.maskedFields)
                mf ~= Json(f);
            j["maskedFields"] = mf;
        }
        if (c.excludedServices.length > 0) {
            auto es = Json.emptyArray;
            foreach (ref s; c.excludedServices)
                es ~= Json(s);
            j["excludedServices"] = es;
        }
        return j;
    }
}
