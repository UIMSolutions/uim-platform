/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.activity;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ActivityController : PlatformController {
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
            auto jarr = items.map!(e => activityToJson(e)).array;
            
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
            if (e.isNull) { writeError(res, 404, "Activity not found"); return; }
            res.writeJsonBody(activityToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ActivityDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.serviceCallId = j.getString("serviceCallId");
            dto.technicianId = j.getString("technicianId");
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.activityType = j.getString("activityType");
            dto.plannedStart = j.getString("plannedStart");
            dto.plannedEnd = j.getString("plannedEnd");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.notes = j.getString("notes");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", Json("Activity created"));

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
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.plannedStart = j.getString("plannedStart");
            dto.plannedEnd = j.getString("plannedEnd");
            dto.actualStart = j.getString("actualStart");
            dto.actualEnd = j.getString("actualEnd");
            dto.notes = j.getString("notes");
            dto.feedbackCode = j.getString("feedbackCode");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Activity updated"));

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
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Activity deleted"));

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
