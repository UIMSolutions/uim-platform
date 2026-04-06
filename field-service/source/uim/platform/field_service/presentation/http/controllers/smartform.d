/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.smartform;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class SmartformController : SAPController {
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
            foreach (ref e; items) jarr ~= smartformToJson(e);
            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) items.length);
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
            auto id = extractIdFromPath(path);
            auto e = uc.get_(id);
            if (e is null) { writeError(res, 404, "Smartform not found"); return; }
            res.writeJsonBody(smartformToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SmartformDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.serviceCallId = jsonStr(j, "serviceCallId");
            dto.activityId = jsonStr(j, "activityId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.formType = jsonStr(j, "formType");
            dto.templateId = jsonStr(j, "templateId");
            dto.safetyLabel = jsonStr(j, "safetyLabel");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Smartform created");
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
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.formData = jsonStr(j, "formData");
            dto.signatureData = jsonStr(j, "signatureData");
            dto.submittedBy = jsonStr(j, "submittedBy");
            dto.submittedDate = jsonStr(j, "submittedDate");
            dto.approvedBy = jsonStr(j, "approvedBy");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Smartform updated");
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
                auto resp = Json.emptyObject;
                resp["message"] = Json("Smartform deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
