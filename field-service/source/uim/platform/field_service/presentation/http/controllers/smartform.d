/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.smartform;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class SmartformController : PlatformController {
    private ManageSmartformsUseCase usecase;

    this(ManageSmartformsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/smartforms", &handleList);
        router.get("/api/v1/field-service/smartforms/*", &handleGet);
        router.post("/api/v1/field-service/smartforms", &handleCreate);
        router.put("/api/v1/field-service/smartforms/*", &handleUpdate);
        router.delete_("/api/v1/field-service/smartforms/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listSmartforms(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = SmartformId(extractIdFromPath(path));

            auto e = usecase.getSmartform(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Smartform not found"); return; }
            res.writeJsonBody(e.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            SmartformDTO dto;
            dto.smartformId = SmartformId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceCallId = ServiceCallId(j.getString("serviceCallId"));
            dto.activityId = ActivityId(j.getString("activityId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.formType = j.getString("formType");
            dto.templateId = j.getString("templateId");
            dto.safetyLabel = j.getString("safetyLabel");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createSmartform(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Smartform created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            SmartformDTO dto;
            dto.smartformId = SmartformId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.formData = j.getString("formData");
            dto.signatureData = j.getString("signatureData");
            dto.submittedBy = UserId(j.getString("submittedBy"));
            dto.submittedDate = j.getString("submittedDate");
            dto.approvedBy = UserId(j.getString("approvedBy"));
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateSmartform(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Smartform updated");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = SmartformId(extractIdFromPath(path));
            auto result = usecase.deleteSmartform(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                .set("message", "Smartform deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
