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
    private ManageSmartformsUseCase uc;

    this(ManageSmartformsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/smartforms", &handleList);
        router.get("/api/v1/field-service/smartforms/*", &handleGet);
        router.post("/api/v1/field-service/smartforms", &handleCreate);
        router.put("/api/v1/field-service/smartforms/*", &handleUpdate);
        router.delete_("/api/v1/field-service/smartforms/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= smartformToJson(e);
            auto resp = Json.emptyObject
                .set("count", Json(items.length))
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(id);
            if (e.isNull) { writeError(res, 404, "Smartform not found"); return; }
            res.writeJsonBody(smartformToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SmartformDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.serviceCallId = j.getString("serviceCallId");
            dto.activityId = j.getString("activityId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.formType = j.getString("formType");
            dto.templateId = j.getString("templateId");
            dto.safetyLabel = j.getString("safetyLabel");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
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

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            SmartformDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.formData = j.getString("formData");
            dto.signatureData = j.getString("signatureData");
            dto.submittedBy = j.getString("submittedBy");
            dto.submittedDate = j.getString("submittedDate");
            dto.approvedBy = j.getString("approvedBy");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(id);
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
