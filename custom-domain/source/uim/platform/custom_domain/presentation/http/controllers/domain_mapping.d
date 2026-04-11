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
    private ManageDomainMappingsUseCase uc;

    this(ManageDomainMappingsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/custom-domain/mappings", &handleList);
        router.get("/api/v1/custom-domain/mappings/*", &handleGet);
        router.post("/api/v1/custom-domain/mappings", &handleCreate);
        router.delete_("/api/v1/custom-domain/mappings/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDomainMappingRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.customDomainId = j.getString("customDomainId");
            r.standardRoute = j.getString("standardRoute");
            r.customRoute = j.getString("customRoute");
            r.mappingType = j.getString("mappingType");
            r.applicationName = j.getString("applicationName");
            r.organizationId = j.getString("organizationId");
            r.spaceId = j.getString("spaceId");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Domain mapping created");
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
            auto mappings = uc.list(tenantId);

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

            auto resp = Json.emptyObject;
            resp["count"] = Json(mappings.length);
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
            auto m = uc.get_(id);
            if (m.id.isEmpty) {
                writeError(res, 404, "Domain mapping not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(m.id);
            resp["customDomainId"] = Json(m.customDomainId);
            resp["standardRoute"] = Json(m.standardRoute);
            resp["customRoute"] = Json(m.customRoute);
            resp["mappingType"] = Json(m.mappingType.to!string);
            resp["status"] = Json(m.status.to!string);
            resp["applicationName"] = Json(m.applicationName);
            resp["organizationId"] = Json(m.organizationId);
            resp["spaceId"] = Json(m.spaceId);
            resp["createdBy"] = Json(m.createdBy);
            resp["createdAt"] = Json(m.createdAt);
            resp["modifiedAt"] = Json(m.modifiedAt);
            res.writeJsonBody(resp, 200);
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
                resp["message"] = Json("Domain mapping deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
