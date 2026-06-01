/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.activity;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ActivityController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listActivities(tenantId);
            auto list = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Activities retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = ActivityId(precheck.id);
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            ActivityDTO dto;
            dto.activityId = ActivityId(precheck.id);
            dto.tenantId = tenantId;
            dto.serviceCallId = ServiceCallId(data.getString("serviceCallId"));
            dto.technicianId = TechnicianId(data.getString("technicianId"));
            dto.subject = data.getString("subject");
            dto.description = data.getString("description");
            dto.activityType = data.getString("activityType");
            dto.plannedStart = data.getString("plannedStart");
            dto.plannedEnd = data.getString("plannedEnd");
            dto.address = data.getString("address");
            dto.latitude = data.getString("latitude");
            dto.longitude = data.getString("longitude");
            dto.notes = data.getString("notes");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createActivity(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Activity created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto data = precheck.data;
            ActivityDTO dto;
            dto.activityId = ActivityId(precheck.id);
            dto.tenantId = tenantId;
            dto.subject = data.getString("subject");
            dto.description = data.getString("description");
            dto.plannedStart = data.getString("plannedStart");
            dto.plannedEnd = data.getString("plannedEnd");
            dto.actualStart = data.getString("actualStart");
            dto.actualEnd = data.getString("actualEnd");
            dto.notes = data.getString("notes");
            dto.feedbackCode = data.getString("feedbackCode");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateActivity(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Activity updated");

                res.writeJsonBody(resp, 200);
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
            auto path = precheck.path;
            auto id = ActivityId(precheck.id);
            auto result = usecase.deleteActivity(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Activity deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
