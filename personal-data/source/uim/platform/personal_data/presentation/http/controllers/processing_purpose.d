/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.processing_purpose;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ProcessingPurposeController : PlatformController {
    private ManageProcessingPurposesUseCase usecase;

    this(ManageProcessingPurposesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/personal-data/purposes", &handleList);
        router.get("/api/v1/personal-data/purposes/*", &handleGet);
        router.post("/api/v1/personal-data/purposes", &handleCreate);
        router.put("/api/v1/personal-data/purposes/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/purposes/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateProcessingPurposeRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.legalBasis = j.getString("legalBasis");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.dataProtectionOfficer = j.getString("dataProtectionOfficer");
            r.requiresConsent = j.getBoolean("requiresConsent");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto purposes = usecase.list(tenantId);

            auto jarr = purposes.map!(p => toJson(p)).array.toJson;

            auto resp = Json.emptyObject
              .set("count", purposes.length)
              .set("resources", jarr)
              .set("message", "Processing purpose list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto p = usecase.getById(tenantId, id);
            if (p.isNull) {
                writeError(res, 404, "Processing purpose not found");
                return;
            }
            res.writeJsonBody(toJson(p), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto j = req.json;
            UpdateProcessingPurposeRequest r;
            r.tenantId = tenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.legalBasis = j.getString("legalBasis");
            r.retentionPeriod = j.getString("retentionPeriod");
            r.dataProtectionOfficer = j.getString("dataProtectionOfficer");
            r.requiresConsent = j.getBoolean("requiresConsent");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = usecase.deleteProcessingPurpose(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing purpose deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json purposeToJson(ProcessingPurpose p) {
        return Json.emptyObject
            .set("id", p.id)
            .set("name", p.name)
            .set("description", p.description)
            .set("status", p.status.to!string)
            .set("legalBasis", p.legalBasis.to!string)
            .set("retentionPeriod", p.retentionPeriod)
            .set("dataProtectionOfficer", p.dataProtectionOfficer)
            .set("requiresConsent", p.requiresConsent)
            .set("createdBy", p.createdBy)
            .set("createdAt", p.createdAt);
    }
}
