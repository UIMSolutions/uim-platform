/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module presentation.http.controllers.api_rule;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.manage_api_rules;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.api_rule;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.presentation.http.json_utils;

class ApiRuleController {
    private ManageApiRulesUseCase uc;

    this(ManageApiRulesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/api-rules", &handleCreate);
        router.get("/api/v1/api-rules", &handleList);
        router.get("/api/v1/api-rules/*", &handleGetById);
        router.put("/api/v1/api-rules/*", &handleUpdate);
        router.delete_("/api/v1/api-rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateApiRuleRequest r;
            r.namespaceId = j.getString("namespaceId");
            r.environmentId = j.getString("environmentId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.serviceName = j.getString("serviceName");
            r.servicePort = j.getInteger("servicePort");
            r.gateway = j.getString("gateway");
            r.host = j.getString("host");
            r.tlsEnabled = j.getBoolean("tlsEnabled", true);
            r.tlsSecretName = j.getString("tlsSecretName");
            r.corsEnabled = j.getBoolean("corsEnabled");
            r.corsAllowOrigins = jsonStrArray(j, "corsAllowOrigins");
            r.corsAllowMethods = jsonStrArray(j, "corsAllowMethods");
            r.corsAllowHeaders = jsonStrArray(j, "corsAllowHeaders");
            r.labels = jsonStrMap(j, "labels");
            r.createdBy = req.headers.get("X-User-Id", "");

            // Parse rules array
            r.rules = parseRuleEntries(j);

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto nsId = req.params.get("namespaceId");
            auto envId = req.params.get("environmentId");

            ApiRule[] items;
            if (nsId.length > 0)
                items = uc.listByNamespace(nsId);
            else if (envId.length > 0)
                items = uc.listByEnvironment(envId);
            else
                items = [];

            auto arr = Json.emptyArray;
            foreach (ref rule; items)
                arr ~= serializeRule(rule);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto rule = uc.getApiRule(id);
            if (rule.id.length == 0) {
                writeError(res, 404, "API rule not found");
                return;
            }
            res.writeJsonBody(serializeRule(rule), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateApiRuleRequest r;
            r.description = j.getString("description");
            r.serviceName = j.getString("serviceName");
            r.servicePort = j.getInteger("servicePort");
            r.host = j.getString("host");
            r.tlsEnabled = j.getBoolean("tlsEnabled", true);
            r.tlsSecretName = j.getString("tlsSecretName");
            r.corsEnabled = j.getBoolean("corsEnabled");
            r.corsAllowOrigins = jsonStrArray(j, "corsAllowOrigins");
            r.corsAllowMethods = jsonStrArray(j, "corsAllowMethods");
            r.corsAllowHeaders = jsonStrArray(j, "corsAllowHeaders");
            r.labels = jsonStrMap(j, "labels");
            r.rules = parseRuleEntries(j);

            auto result = uc.updateApiRule(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteApiRule(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private ApiRuleEntryDto[] parseRuleEntries(Json j) {
        ApiRuleEntryDto[] entries;
        auto v = "rules" in j;
        if (v is null || (*v).type != Json.Type.array)
            return entries;
        foreach (item; *v) {
            ApiRuleEntryDto entry;
            entry.path = item.getString("path");
            entry.methods = jsonStrArray(item, "methods");
            entry.accessStrategy = item.getString("accessStrategy");
            entry.requiredScopes = jsonStrArray(item, "requiredScopes");
            entry.audiences = jsonStrArray(item, "audiences");
            entry.trustedIssuers = jsonStrArray(item, "trustedIssuers");
            entries ~= entry;
        }
        return entries;
    }

    private Json serializeRule(ref ApiRule rule) {
        auto j = Json.emptyObject;
        j["id"] = Json(rule.id);
        j["namespaceId"] = Json(rule.namespaceId);
        j["environmentId"] = Json(rule.environmentId);
        j["tenantId"] = Json(rule.tenantId);
        j["name"] = Json(rule.name);
        j["description"] = Json(rule.description);
        j["status"] = Json(rule.status.to!string);
        j["serviceName"] = Json(rule.serviceName);
        j["servicePort"] = Json(cast(long)rule.servicePort);
        j["gateway"] = Json(rule.gateway);
        j["host"] = Json(rule.host);
        j["tlsEnabled"] = Json(rule.tlsEnabled);
        j["corsEnabled"] = Json(rule.corsEnabled);
        j["labels"] = serializeStrMap(rule.labels);
        j["createdBy"] = Json(rule.createdBy);
        j["createdAt"] = Json(rule.createdAt);
        j["modifiedAt"] = Json(rule.modifiedAt);

        auto rulesArr = Json.emptyArray;
        foreach (ref entry; rule.rules) {
            auto ej = Json.emptyObject;
            ej["path"] = Json(entry.path);
            ej["accessStrategy"] = Json(entry.accessStrategy.to!string);
            ej["requiredScopes"] = serializeStrArray(entry.requiredScopes);
            ej["audiences"] = serializeStrArray(entry.audiences);

            auto mArr = Json.emptyArray;
            foreach (ref m; entry.methods)
                mArr ~= Json(m.to!string);
            ej["methods"] = mArr;

            rulesArr ~= ej;
        }
        j["rules"] = rulesArr;

        return j;
    }
}
