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
    private ManageActivitiesUseCase usecase;

    this(ManageActivitiesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/activities", &handleList);
        router.get("/api/v1/field-service/activities/*", &handleGet);
        router.post("/api/v1/field-service/activities", &handleCreate);
        router.put("/api/v1/field-service/activities/*", &handleUpdate);
        router.delete_("/api/v1/field-service/activities/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listActivities(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Activities retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ActivityId(extractIdFromPath(path));
            Activity activity = usecase.getActivity(tenantId, id);
            if (activity.isNull) {
                writeError(res, 404, "Activity not found");
                return;
            }
            res.writeJsonBody(activity.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ActivityDTO dto;
            dto.activityId = ActivityId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.serviceCallId = ServiceCallId(j.getString("serviceCallId"));
            dto.technicianId = TechnicianId(j.getString("technicianId"));
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.activityType = j.getString("activityType");
            dto.plannedStart = j.getString("plannedStart");
            dto.plannedEnd = j.getString("plannedEnd");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.notes = j.getString("notes");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createActivity(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Activity created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            ActivityDTO dto;
            dto.activityId = ActivityId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.plannedStart = j.getString("plannedStart");
            dto.plannedEnd = j.getString("plannedEnd");
            dto.actualStart = j.getString("actualStart");
            dto.actualEnd = j.getString("actualEnd");
            dto.notes = j.getString("notes");
            dto.feedbackCode = j.getString("feedbackCode");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateActivity(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Activity updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ActivityId(extractIdFromPath(path));
            auto result = usecase.deleteActivity(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Activity deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
