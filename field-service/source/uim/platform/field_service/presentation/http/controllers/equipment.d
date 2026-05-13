/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class EquipmentController : PlatformController {
    private ManageEquipmentUseCase usecase;

    this(ManageEquipmentUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/field-service/equipment", &handleList);
        router.get("/api/v1/field-service/equipment/*", &handleGet);
        router.post("/api/v1/field-service/equipment", &handleCreate);
        router.put("/api/v1/field-service/equipment/*", &handleUpdate);
        router.delete_("/api/v1/field-service/equipment/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listEquipments(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Equipment list retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EquipmentId(extractIdFromPath(path));
            auto equipment = usecase.getEquipment(tenantId, id);
            if (equipment.isNull) { writeError(res, 404, "Equipment not found"); return; }
            res.writeJsonBody(equipment.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            EquipmentDTO dto;
            dto.equipmentId = EquipmentId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.customerId = CustomerId(j.getString("customerId"))  ;
            dto.serialNumber = j.getString("serialNumber");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.equipmentType = j.getString("equipmentType");
            dto.manufacturer = j.getString("manufacturer");
            dto.model = j.getString("model");
            dto.installationDate = j.getString("installationDate");
            dto.warrantyEndDate = j.getString("warrantyEndDate");
            dto.locationAddress = j.getString("locationAddress");
            dto.latitude = j.getString("latitude");
            dto.longitude = j.getString("longitude");
            dto.measuringPoint = j.getString("measuringPoint");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createEquipment(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Equipment created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            EquipmentDTO dto;
            dto.equipmentId = EquipmentId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.manufacturer = j.getString("manufacturer");
            dto.model = j.getString("model");
            dto.locationAddress = j.getString("locationAddress");
            dto.lastServiceDate = j.getString("lastServiceDate");
            dto.nextServiceDate = j.getString("nextServiceDate");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateEquipment(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Equipment updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EquipmentId(extractIdFromPath(path));
            auto result = usecase.deleteEquipment(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Equipment deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
