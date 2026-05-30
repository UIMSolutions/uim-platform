/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class EquipmentController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listEquipments(tenantId);
            auto list = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Equipment list retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = EquipmentId(precheck.id);
            auto equipment = usecase.getEquipment(tenantId, id);
            if (equipment.isNull) { writeError(res, 404, "Equipment not found"); return; }
            res.writeJsonBody(equipment.toJson, 200);
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
            EquipmentDTO dto;
            dto.equipmentId = EquipmentId(precheck.id);
            dto.tenantId = tenantId;
            dto.customerId = CustomerId(data.getString("customerId"))  ;
            dto.serialNumber = data.getString("serialNumber");
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.equipmentType = data.getString("equipmentType");
            dto.manufacturer = data.getString("manufacturer");
            dto.model = data.getString("model");
            dto.installationDate = data.getString("installationDate");
            dto.warrantyEndDate = data.getString("warrantyEndDate");
            dto.locationAddress = data.getString("locationAddress");
            dto.latitude = data.getString("latitude");
            dto.longitude = data.getString("longitude");
            dto.measuringPoint = data.getString("measuringPoint");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createEquipment(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Equipment created");

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
            auto data = precheck.data;
            EquipmentDTO dto;
            dto.equipmentId = EquipmentId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.manufacturer = data.getString("manufacturer");
            dto.model = data.getString("model");
            dto.locationAddress = data.getString("locationAddress");
            dto.lastServiceDate = data.getString("lastServiceDate");
            dto.nextServiceDate = data.getString("nextServiceDate");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateEquipment(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Equipment updated");

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
            auto path = req.requestURI.to!string;
            auto id = EquipmentId(precheck.id);
            auto result = usecase.deleteEquipment(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Equipment deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
