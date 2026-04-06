/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.equipment;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class EquipmentController : SAPController {
    private ManageEquipmentUseCase uc;

    this(ManageEquipmentUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/equipment", &handleList);
        router.get("/api/v1/network-asset-collaboration/equipment/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/equipment", &handleCreate);
        router.put("/api/v1/network-asset-collaboration/equipment/*", &handleUpdate);
        router.delete_("/api/v1/network-asset-collaboration/equipment/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto params = req.queryParams();
            auto manufacturer = params.get("manufacturer", "");
            auto status = params.get("status", "");

            Equipment[] items;
            if (manufacturer.length > 0) {
                items = uc.listByManufacturer(manufacturer);
            } else {
                items = uc.list();
            }

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
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.modelId = jsonStr(j, "modelId");
            dto.serialNumber = jsonStr(j, "serialNumber");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.manufacturer = jsonStr(j, "manufacturer");
            dto.operatorCompanyId = jsonStr(j, "operatorCompanyId");
            dto.location = jsonStr(j, "location");
            dto.latitude = jsonStr(j, "latitude");
            dto.longitude = jsonStr(j, "longitude");
            dto.installationDate = jsonStr(j, "installationDate");
            dto.commissioningDate = jsonStr(j, "commissioningDate");
            dto.warrantyEndDate = jsonStr(j, "warrantyEndDate");
            dto.batchNumber = jsonStr(j, "batchNumber");
            dto.firmwareVersion = jsonStr(j, "firmwareVersion");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Equipment created");
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
            EquipmentDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.location = jsonStr(j, "location");
            dto.firmwareVersion = jsonStr(j, "firmwareVersion");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Equipment updated");
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
                resp["message"] = Json("Equipment deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
