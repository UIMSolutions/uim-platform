/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class EquipmentController : SAPController {
    private ManageEquipmentUseCase uc;

    this(ManageEquipmentUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/field-service/equipment", &handleList);
        router.get("/api/v1/field-service/equipment/*", &handleGet);
        router.post("/api/v1/field-service/equipment", &handleCreate);
        router.put("/api/v1/field-service/equipment/*", &handleUpdate);
        router.delete_("/api/v1/field-service/equipment/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref e; items) jarr ~= equipmentToJson(e);
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
            if (e is null) { writeError(res, 404, "Equipment not found"); return; }
            res.writeJsonBody(equipmentToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            EquipmentDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.customerId = j.getString("customerId");
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
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Equipment created");
                res.writeJsonBody(resp, 201);
            } ) {
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
            EquipmentDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.manufacturer = j.getString("manufacturer");
            dto.model = j.getString("model");
            dto.locationAddress = j.getString("locationAddress");
            dto.lastServiceDate = j.getString("lastServiceDate");
            dto.nextServiceDate = j.getString("nextServiceDate");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Equipment updated");
                res.writeJsonBody(resp, 200);
            } ) {
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
                resp["message"] = Json("Equipment deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
