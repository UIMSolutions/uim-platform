/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.technician;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class TechnicianController : PlatformController {
    private ManageTechniciansUseCase uc;

    this(ManageTechniciansUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/technicians", &handleList);
        router.get("/api/v1/field-service/technicians/*", &handleGet);
        router.post("/api/v1/field-service/technicians", &handleCreate);
        router.put("/api/v1/field-service/technicians/*", &handleUpdate);
        router.delete_("/api/v1/field-service/technicians/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => technicianToJson(e)).array;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
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
            if (e.isNull) { writeError(res, 404, "Technician not found"); return; }
            res.writeJsonBody(technicianToJson(e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            TechnicianDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.region = j.getString("region");
            dto.address = j.getString("address");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.availabilityStart = j.getString("availabilityStart");
            dto.availabilityEnd = j.getString("availabilityEnd");
            dto.maxWorkload = j.getString("maxWorkload");
            dto.travelRadius = j.getString("travelRadius");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Technician created");
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
            TechnicianDTO dto;
            dto.id = extractIdFromPath(path);
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.region = j.getString("region");
            dto.address = j.getString("address");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Technician updated");

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
                  .set("message", "Technician deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
