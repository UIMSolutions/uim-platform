/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.custom_domain;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CustomDomainController : SAPController {
    private ManageCustomDomainsUseCase uc;

    this(ManageCustomDomainsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/custom-domain/domains", &handleList);
        router.get("/api/v1/custom-domain/domains/*", &handleGet);
        router.post("/api/v1/custom-domain/domains", &handleCreate);
        router.put("/api/v1/custom-domain/domains/*", &handleUpdate);
        router.post("/api/v1/custom-domain/domains/*/activate", &handleActivate);
        router.post("/api/v1/custom-domain/domains/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/custom-domain/domains/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateCustomDomainRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.domainName = j.getString("domainName");
            r.organizationId = j.getString("organizationId");
            r.spaceId = j.getString("spaceId");
            r.environment = j.getString("environment");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Custom domain created");
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
            auto tenantId = req.getTenantId;
            auto domains = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref d; domains) {
                auto dj = Json.emptyObject;
                dj["id"] = Json(d.id);
                dj["domainName"] = Json(d.domainName);
                dj["status"] = Json(d.status.to!string);
                dj["organizationId"] = Json(d.organizationId);
                dj["spaceId"] = Json(d.spaceId);
                dj["activeCertificateId"] = Json(d.activeCertificateId);
                dj["isShared"] = Json(d.isShared);
                dj["clientAuthEnabled"] = Json(d.clientAuthEnabled);
                dj["createdBy"] = Json(d.createdBy);
                dj["createdAt"] = Json(d.createdAt);
                jarr ~= dj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) domains.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            // Check for /activate or /deactivate suffix — skip
            if (path.length > 9 && path[$ - 9 .. $] == "/activate")
                return;
            if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
                return;

            auto id = extractIdFromPath(path);
            auto d = uc.get_(id);
            if (d.id.length == 0) {
                writeError(res, 404, "Custom domain not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(d.id);
            resp["domainName"] = Json(d.domainName);
            resp["status"] = Json(d.status.to!string);
            resp["environment"] = Json(d.environment.to!string);
            resp["organizationId"] = Json(d.organizationId);
            resp["spaceId"] = Json(d.spaceId);
            resp["activeCertificateId"] = Json(d.activeCertificateId);
            resp["tlsConfigurationId"] = Json(d.tlsConfigurationId);
            resp["isShared"] = Json(d.isShared);
            resp["sharedWithOrgs"] = Json(d.sharedWithOrgs);
            resp["clientAuthEnabled"] = Json(d.clientAuthEnabled);
            resp["createdBy"] = Json(d.createdBy);
            resp["modifiedBy"] = Json(d.modifiedBy);
            resp["createdAt"] = Json(d.createdAt);
            resp["modifiedAt"] = Json(d.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateCustomDomainRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.activeCertificateId = j.getString("activeCertificateId");
            r.tlsConfigurationId = j.getString("tlsConfigurationId");
            r.isShared = jsonBool(j, "isShared");
            r.sharedWithOrgs = j.getString("sharedWithOrgs");
            r.clientAuthEnabled = jsonBool(j, "clientAuthEnabled");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Custom domain updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            // path: /api/v1/custom-domain/domains/{id}/activate
            // Extract ID: strip /activate suffix, then extract last segment
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);

            auto result = uc.activate(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Custom domain activated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);

            auto result = uc.deactivate(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Custom domain deactivated");
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
                resp["message"] = Json("Custom domain deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
