/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.tls_configuration;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class TlsConfigurationController : PlatformController {
    private ManageTlsConfigurationsUseCase uc;

    this(ManageTlsConfigurationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/custom-domain/tls-configurations", &handleList);
        router.get("/api/v1/custom-domain/tls-configurations/*", &handleGet);
        router.post("/api/v1/custom-domain/tls-configurations", &handleCreate);
        router.put("/api/v1/custom-domain/tls-configurations/*", &handleUpdate);
        router.delete_("/api/v1/custom-domain/tls-configurations/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTlsConfigurationRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.minProtocolVersion = j.getString("minProtocolVersion");
            r.maxProtocolVersion = j.getString("maxProtocolVersion");
            r.http2Enabled = jsonBool(j, "http2Enabled");
            r.hstsEnabled = jsonBool(j, "hstsEnabled");
            r.hstsMaxAge = jsonLong(j, "hstsMaxAge");
            r.hstsIncludeSubDomains = jsonBool(j, "hstsIncludeSubDomains");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("TLS configuration created");
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
            TenantId tenantId = req.getTenantId;
            auto configs = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (c; configs) {
                auto cj = Json.emptyObject;
                cj["id"] = Json(c.id);
                cj["name"] = Json(c.name);
                cj["description"] = Json(c.description);
                cj["minProtocolVersion"] = Json(c.minProtocolVersion.to!string);
                cj["maxProtocolVersion"] = Json(c.maxProtocolVersion.to!string);
                cj["http2Enabled"] = Json(c.http2Enabled);
                cj["hstsEnabled"] = Json(c.hstsEnabled);
                cj["createdBy"] = Json(c.createdBy);
                cj["createdAt"] = Json(c.createdAt);
                jarr ~= cj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(configs.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto c = uc.get_(id);
            if (c.id.isEmpty) {
                writeError(res, 404, "TLS configuration not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(c.id);
            resp["name"] = Json(c.name);
            resp["description"] = Json(c.description);
            resp["minProtocolVersion"] = Json(c.minProtocolVersion.to!string);
            resp["maxProtocolVersion"] = Json(c.maxProtocolVersion.to!string);
            resp["http2Enabled"] = Json(c.http2Enabled);
            resp["hstsEnabled"] = Json(c.hstsEnabled);
            resp["hstsMaxAge"] = Json(c.hstsMaxAge);
            resp["hstsIncludeSubDomains"] = Json(c.hstsIncludeSubDomains);
            resp["createdBy"] = Json(c.createdBy);
            resp["modifiedBy"] = Json(c.modifiedBy);
            resp["createdAt"] = Json(c.createdAt);
            resp["modifiedAt"] = Json(c.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateTlsConfigurationRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.minProtocolVersion = j.getString("minProtocolVersion");
            r.maxProtocolVersion = j.getString("maxProtocolVersion");
            r.http2Enabled = jsonBool(j, "http2Enabled");
            r.hstsEnabled = jsonBool(j, "hstsEnabled");
            r.hstsMaxAge = jsonLong(j, "hstsMaxAge");
            r.hstsIncludeSubDomains = jsonBool(j, "hstsIncludeSubDomains");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("TLS configuration updated");
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
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("TLS configuration deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
