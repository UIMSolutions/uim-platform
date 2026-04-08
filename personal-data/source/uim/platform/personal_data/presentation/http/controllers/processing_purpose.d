/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.processing_purpose;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ProcessingPurposeController : SAPController {
    private ManageProcessingPurposesUseCase uc;

    this(ManageProcessingPurposesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/personal-data/purposes", &handleList);
        router.get("/api/v1/personal-data/purposes/*", &handleGet);
        router.post("/api/v1/personal-data/purposes", &handleCreate);
        router.put("/api/v1/personal-data/purposes/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/purposes/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateProcessingPurposeRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.legalBasis = j.getString("legalBasis");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.dataProtectionOfficer = j.getString("dataProtectionOfficer");
            r.requiresConsent = jsonBool(j, "requiresConsent");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Processing purpose created");
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
            auto tenantId = req.getTenantId;
            auto purposes = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref p; purposes) {
                jarr ~= purposeToJson(p);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) purposes.length);
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
            auto p = uc.get_(id);
            if (p.id.length == 0) {
                writeError(res, 404, "Processing purpose not found");
                return;
            }
            res.writeJsonBody(purposeToJson(p), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateProcessingPurposeRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.legalBasis = j.getString("legalBasis");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.dataProtectionOfficer = j.getString("dataProtectionOfficer");
            r.requiresConsent = jsonBool(j, "requiresConsent");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Processing purpose updated");
                res.writeJsonBody(resp, 200);
            } ) {
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
                resp["message"] = Json("Processing purpose deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json purposeToJson(ref ProcessingPurpose p) {
        auto j = Json.emptyObject;
        j["id"] = Json(p.id);
        j["name"] = Json(p.name);
        j["description"] = Json(p.description);
        j["status"] = Json(p.status.to!string);
        j["legalBasis"] = Json(p.legalBasis.to!string);
        j["retentionPeriod"] = Json(p.retentionPeriod);
        j["dataProtectionOfficer"] = Json(p.dataProtectionOfficer);
        j["requiresConsent"] = Json(p.requiresConsent);
        j["createdBy"] = Json(p.createdBy);
        j["createdAt"] = Json(p.createdAt);
        return j;
    }
}
