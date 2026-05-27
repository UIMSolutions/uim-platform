/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.technician;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class TechnicianController : ManageController {
    private ManageTechniciansUseCase usecase;

    this(ManageTechniciansUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/technicians", &handleList);
        router.get("/api/v1/field-service/technicians/*", &handleGet);
        router.post("/api/v1/field-service/technicians", &handleCreate);
        router.put("/api/v1/field-service/technicians/*", &handleUpdate);
        router.delete_("/api/v1/field-service/technicians/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listTechnicians(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = TechnicianId(precheck.id);
            auto e = usecase.getTechnician(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Technician not found"); return; }
            res.writeJsonBody(e.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            TechnicianDTO dto;
            dto.technicianId = TechnicianId(precheck.id);
            dto.tenantId = tenantId;
            dto.firstName = data.getString("firstName");
            dto.lastName = data.getString("lastName");
            dto.email = data.getString("email");
            dto.phone = data.getString("phone");
            dto.region = data.getString("region");
            dto.address = data.getString("address");
            dto.latitude = data.getString("latitude");
            dto.longitude = data.getString("longitude");
            dto.availabilityStart = data.getString("availabilityStart");
            dto.availabilityEnd = data.getString("availabilityEnd");
            dto.maxWorkload = data.getString("maxWorkload");
            dto.travelRadius = data.getString("travelRadius");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createTechnician(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Technician created");
                res.writeJsonBody(resp, 201);
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
            auto j = req.json;
            TechnicianDTO dto;
            dto.technicianId = TechnicianId(precheck.id);
            dto.tenantId = tenantId;
            dto.firstName = data.getString("firstName");
            dto.lastName = data.getString("lastName");
            dto.email = data.getString("email");
            dto.phone = data.getString("phone");
            dto.region = data.getString("region");
            dto.address = data.getString("address");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateTechnician(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Technician updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = TechnicianId(precheck.id);
            auto result = usecase.deleteTechnician(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Technician deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
