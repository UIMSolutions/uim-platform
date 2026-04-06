/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.activity;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ActivityController : SAPController {
    private ManageActivitiesUseCase uc;

    this(ManageActivitiesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/field-service/activities", &handleList);
        router.get("/api/v1/field-service/activities/*", &handleGet);
        router.post("/api/v1/field-service/activities", &handleCreate);
        router.put("/api/v1/field-service/activities/*", &handleUpdate);
        router.delete_("/api/v1/field-service/activities/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref e; items) jarr ~= activityToJson(e);
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
            if (e is null) { writeError(res, 404, "Activity not found"); return; }
            res.writeJsonBody(activityToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ActivityDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.serviceCallId = jsonStr(j, "serviceCallId");
            dto.technicianId = jsonStr(j, "technicianId");
            dto.subject = jsonStr(j, "subject");
            dto.description = jsonStr(j, "description");
            dto.activityType = jsonStr(j, "activityType");
            dto.plannedStart = jsonStr(j, "plannedStart");
            dto.plannedEnd = jsonStr(j, "plannedEnd");
            dto.address = jsonStr(j, "address");
            dto.latitude = jsonStr(j, "latitude");
            dto.longitude = jsonStr(j, "longitude");
            dto.notes = jsonStr(j, "notes");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Activity created");
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
            ActivityDTO dto;
            dto.id = extractIdFromPath(path);
            dto.subject = jsonStr(j, "subject");
            dto.description = jsonStr(j, "description");
            dto.plannedStart = jsonStr(j, "plannedStart");
            dto.plannedEnd = jsonStr(j, "plannedEnd");
            dto.actualStart = jsonStr(j, "actualStart");
            dto.actualEnd = jsonStr(j, "actualEnd");
            dto.notes = jsonStr(j, "notes");
            dto.feedbackCode = jsonStr(j, "feedbackCode");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Activity updated");
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
                resp["message"] = Json("Activity deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
