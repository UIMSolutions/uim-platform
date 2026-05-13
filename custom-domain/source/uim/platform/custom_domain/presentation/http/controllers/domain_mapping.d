/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.domain_mapping;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DomainMappingController : PlatformController {
    private ManageDomainMappingsUseCase usecase;

    this(ManageDomainMappingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/mappings", &handleList);
        router.get("/api/v1/custom-domain/mappings/*", &handleGet);
        router.post("/api/v1/custom-domain/mappings", &handleCreate);
        router.delete_("/api/v1/custom-domain/mappings/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateDomainMappingRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.customDomainId = j.getString("customDomainId");
            r.standardRoute = j.getString("standardRoute");
            r.customRoute = j.getString("customRoute");
            r.mappingType = j.getString("mappingType");
            r.applicationName = j.getString("applicationName");
            r.organizationId = j.getString("organizationId");
            r.spaceId = j.getString("spaceId");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDomainMapping(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Domain mapping created");

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
            auto mappings = usecase.listDomainMappings(tenantId);

            auto jarr = Json.emptyArray;
            foreach (m; mappings) {
                jarr ~= Json.emptyObject
                    .set("id", m.id)
                    .set("customDomainId", m.customDomainId)
                    .set("standardRoute", m.standardRoute)
                    .set("customRoute", m.customRoute)
                    .set("mappingType", m.mappingType.to!string)
                    .set("status", m.status.to!string)
                    .set("applicationName", m.applicationName)
                    .set("createdBy", m.createdBy)
                    .set("createdAt", m.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", Json(mappings.length))
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);

            auto m = usecase.getDomainMapping(tenantId, id);
            if (m.isNull) {
                writeError(res, 404, "Domain mapping not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", m.id)
                .set("customDomainId", m.customDomainId)
                .set("standardRoute", m.standardRoute)
                .set("customRoute", m.customRoute)
                .set("mappingType", m.mappingType.to!string)
                .set("status", m.status.to!string)
                .set("applicationName", m.applicationName)
                .set("organizationId", m.organizationId)
                .set("spaceId", m.spaceId)
                .set("createdBy", m.createdBy)
                .set("createdAt", m.createdAt)
                .set("updatedAt", m.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DomainMappingId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteDomainMapping(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Domain mapping deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
