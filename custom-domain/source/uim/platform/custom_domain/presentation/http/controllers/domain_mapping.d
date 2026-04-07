/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.domain_mapping;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DomainMappingController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.customDomainId = jsonStr(j, "customDomainId");
            r.standardRoute = jsonStr(j, "standardRoute");
            r.customRoute = jsonStr(j, "customRoute");
            r.mappingType = jsonStr(j, "mappingType");
            r.applicationName = jsonStr(j, "applicationName");
            r.organizationId = jsonStr(j, "organizationId");
            r.spaceId = jsonStr(j, "spaceId");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Domain mapping created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto mappings = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref m; mappings) {
                auto mj = Json.emptyObject;
                mj["id"] = Json(m.id);
                mj["customDomainId"] = Json(m.customDomainId);
                mj["standardRoute"] = Json(m.standardRoute);
                mj["customRoute"] = Json(m.customRoute);
                mj["mappingType"] = Json(m.mappingType.to!string);
                mj["status"] = Json(m.status.to!string);
                mj["applicationName"] = Json(m.applicationName);
                mj["createdBy"] = Json(m.createdBy);
                mj["createdAt"] = Json(m.createdAt);
                jarr ~= mj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) mappings.length);
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
            if (m.id.length == 0) {
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
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
