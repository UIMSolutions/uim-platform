/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.custom_domain;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CustomDomainController : PlatformController {
    private ManageCustomDomainsUseCase usecase;

    this(ManageCustomDomainsUseCase usecase) {
        this.usecase = usecase;
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateCustomDomainRequest r;
            r.tenantId = tenantId;
            r.customDomainId = CustomDomainId(j.getString("id"));
            r.domainName = j.getString("domainName");
            r.organizationId = j.getString("organizationId");
            r.spaceId = j.getString("spaceId");
            r.environment = j.getString("environment");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDomain(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Custom domain created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto domains = usecase.listDomains(tenantId);

            auto jarr = Json.emptyArray;
            foreach (d; domains) {
                jarr ~= Json.emptyObject
                    .set("id", d.id)
                    .set("domainName", d.domainName)
                    .set("status", d.status.to!string)
                    .set("organizationId", d.organizationId)
                    .set("spaceId", d.spaceId)
                    .set("activeCertificateId", d.activeCertificateId)
                    .set("isShared", d.isShared)
                    .set("clientAuthEnabled", d.clientAuthEnabled)
                    .set("createdBy", d.createdBy)
                    .set("createdAt", d.createdAt);
            }

            auto response = Json.emptyObject;
            response["count"] = Json(domains.length);
            response["resources"] = jarr;
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            
            // Check for /activate or /deactivate suffix — skip
            if (path.length > 9 && path[$ - 9 .. $] == "/activate")
                return;
            if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
                return;

            auto id = CustomDomainId(extractIdFromPath(path));
            auto d = usecase.getDomain(tenantId, id);
            if (d.isNull) {
                writeError(res, 404, "Custom domain not found");
                return;
            }

            auto response = Json.emptyObject
                .set("id", d.id)
                .set("domainName", d.domainName)
                .set("status", d.status.to!string)
                .set("environment", d.environment.to!string)
                .set("organizationId", d.organizationId)
                .set("spaceId", d.spaceId)
                .set("activeCertificateId", d.activeCertificateId)
                .set("tlsConfigurationId", d.tlsConfigurationId)
                .set("isShared", d.isShared)
                .set("sharedWithOrgs", d.sharedWithOrgs)
                .set("clientAuthEnabled", d.clientAuthEnabled)
                .set("createdBy", d.createdBy)
                .set("updatedBy", d.updatedBy)
                .set("createdAt", d.createdAt)
                .set("updatedAt", d.updatedAt);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = CustomDomainId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateCustomDomainRequest r;
            r.customDomainId = id;
            r.tenantId = tenantId;
            r.activeCertificateId = j.getString("activeCertificateId");
            r.tlsConfigurationId = j.getString("tlsConfigurationId");
            r.isShared = j.getBoolean("isShared");
            r.sharedWithOrgs = j.getString("sharedWithOrgs");
            r.clientAuthEnabled = j.getBoolean("clientAuthEnabled");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDomain(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Custom domain updated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            // path: /api/v1/custom-domain/domains/{id}/activate
            // Extract ID: strip /activate suffix, then extract last segment
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = CustomDomainId(extractIdFromPath(stripped));

            auto result = usecase.activateDomain(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Custom domain activated");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = CustomDomainId(extractIdFromPath(stripped));

            auto result = usecase.deactivateDomain(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Custom domain deactivated");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = CustomDomainId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteDomain(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Custom domain deleted");
                    
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
