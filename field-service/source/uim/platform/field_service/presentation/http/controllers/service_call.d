/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.service_call;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ServiceCallController : SAPController {
    private ManageServiceCallsUseCase uc;

    this(ManageServiceCallsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/field-service/service-calls", &handleList);
        router.get("/api/v1/field-service/service-calls/*", &handleGet);
        router.post("/api/v1/field-service/service-calls", &handleCreate);
        router.put("/api/v1/field-service/service-calls/*", &handleUpdate);
        router.delete_("/api/v1/field-service/service-calls/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref e; items) jarr ~= serviceCallToJson(e);
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
            if (e is null) { writeError(res, 404, "Service call not found"); return; }
            res.writeJsonBody(serviceCallToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ServiceCallDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.customerId = j.getString("customerId");
            dto.equipmentId = j.getString("equipmentId");
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.serviceType = j.getString("serviceType");
            dto.contactPerson = j.getString("contactPerson");
            dto.contactPhone = j.getString("contactPhone");
            dto.contactEmail = j.getString("contactEmail");
            dto.reportedDate = j.getString("reportedDate");
            dto.dueDate = j.getString("dueDate");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Service call created");
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
            ServiceCallDTO dto;
            dto.id = extractIdFromPath(path);
            dto.subject = j.getString("subject");
            dto.description = j.getString("description");
            dto.contactPerson = j.getString("contactPerson");
            dto.contactPhone = j.getString("contactPhone");
            dto.contactEmail = j.getString("contactEmail");
            dto.resolution = j.getString("resolution");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Service call updated");
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
                resp["message"] = Json("Service call deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
