/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.assignment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class AssignmentController : PlatformController {
    private ManageAssignmentsUseCase usecase;

    this(ManageAssignmentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/assignments", &handleList);
        router.get("/api/v1/field-service/assignments/*", &handleGet);
        router.post("/api/v1/field-service/assignments", &handleCreate);
        router.put("/api/v1/field-service/assignments/*", &handleUpdate);
        router.delete_("/api/v1/field-service/assignments/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto assignments = usecase.listAssignments(tenantId);
            auto jsonAssignments = assignments.map!(assignment => assignment.toJson).array.toJson;
            auto response = Json.emptyObject
                .set("count", assignments.length)
                .set("resources", jsonAssignments);
    
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AssignmentId(extractIdFromPath(path));

            auto e = usecase.getAssignment(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Assignment not found");
                return;
            }
            res.writeJsonBody(e.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            AssignmentDTO dto;
            dto.assignmentId = AssignmentId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.activityId = j.getString("activityId");
            dto.technicianId = j.getString("technicianId");
            dto.assignedDate = j.getString("assignedDate");
            dto.schedulingPolicy = j.getString("schedulingPolicy");
            dto.matchScore = j.getString("matchScore");
            dto.notes = j.getString("notes");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createAssignment(dto);
            if (result.success) {
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Assignment created");
                res.writeJsonBody(response, 201);
            } else {
                writeError(res, 400, result.errorMessage);
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

            AssignmentDTO dto;
            dto.assignmentId = AssignmentId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.acceptedDate = j.getString("acceptedDate");
            dto.startedDate = j.getString("startedDate");
            dto.completedDate = j.getString("completedDate");
            dto.travelDistance = j.getString("travelDistance");
            dto.notes = j.getString("notes");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateAssignment(dto);
            if (result.success) {
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Assignment updated");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AssignmentId(extractIdFromPath(path));
            auto result = usecase.deleteAssignment(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject;
                response["message"] = Json("Assignment deleted");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
