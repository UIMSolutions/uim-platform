/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.assignment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class AssignmentController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;


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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = AssignmentId(precheck.id);

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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            AssignmentDTO dto;
            dto.assignmentId = AssignmentId(precheck.id);
            dto.tenantId = tenantId;
            dto.activityId = data.getString("activityId");
            dto.technicianId = data.getString("technicianId");
            dto.assignedDate = data.getString("assignedDate");
            dto.schedulingPolicy = data.getString("schedulingPolicy");
            dto.matchScore = data.getString("matchScore");
            dto.notes = data.getString("notes");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createAssignment(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Assignment created");
                res.writeJsonBody(response, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            AssignmentDTO dto;
            dto.assignmentId = AssignmentId(precheck.id);
            dto.tenantId = tenantId;
            dto.acceptedDate = data.getString("acceptedDate");
            dto.startedDate = data.getString("startedDate");
            dto.completedDate = data.getString("completedDate");
            dto.travelDistance = data.getString("travelDistance");
            dto.notes = data.getString("notes");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateAssignment(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject;
                response["id"] = Json(result.id);
                response["message"] = Json("Assignment updated");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = AssignmentId(precheck.id);
            auto result = usecase.deleteAssignment(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject;
                response["message"] = Json("Assignment deleted");
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
