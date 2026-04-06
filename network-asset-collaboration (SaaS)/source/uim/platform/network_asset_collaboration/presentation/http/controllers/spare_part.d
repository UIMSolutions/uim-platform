/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.spare_part;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class SparePartController : SAPController {
    private ManageSparePartsUseCase uc;

    this(ManageSparePartsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/spare-parts", &handleList);
        router.get("/api/v1/network-asset-collaboration/spare-parts/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/spare-parts", &handleCreate);
        router.put("/api/v1/network-asset-collaboration/spare-parts/*", &handleUpdate);
        router.delete_("/api/v1/network-asset-collaboration/spare-parts/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto params = req.queryParams();
            auto modelId = params.get("modelId", "");
            auto manufacturer = params.get("manufacturer", "");

            SparePart[] items;
            if (modelId.length > 0) {
                items = uc.listByModel(modelId);
            } else if (manufacturer.length > 0) {
                items = uc.listByManufacturer(manufacturer);
            } else {
                items = uc.list();
            }

            auto jarr = Json.emptyArray;
            foreach (ref sp; items) jarr ~= sparePartToJson(sp);
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
            auto sp = uc.get_(id);
            if (sp is null) { writeError(res, 404, "Spare part not found"); return; }
            res.writeJsonBody(sparePartToJson(*sp), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SparePartDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.modelId = jsonStr(j, "modelId");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.partNumber = jsonStr(j, "partNumber");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.manufacturer = jsonStr(j, "manufacturer");
            dto.category = jsonStr(j, "category");
            dto.quantity = jsonLong(j, "quantity", 0);
            dto.unit = jsonStr(j, "unit");
            dto.leadTimeDays = jsonStr(j, "leadTimeDays");
            dto.isCritical = jsonBool(j, "isCritical", false);
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Spare part created");
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
            SparePartDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.manufacturer = jsonStr(j, "manufacturer");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Spare part updated");
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
                resp["message"] = Json("Spare part deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
