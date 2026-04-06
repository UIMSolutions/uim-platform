/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.indicator;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class IndicatorController : SAPController {
    private ManageIndicatorsUseCase uc;

    this(ManageIndicatorsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/indicators", &handleList);
        router.get("/api/v1/network-asset-collaboration/indicators/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/indicators", &handleCreate);
        router.delete_("/api/v1/network-asset-collaboration/indicators/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto params = req.queryParams();
            auto equipmentId = params.get("equipmentId", "");

            Indicator[] items;
            if (equipmentId.length > 0) {
                items = uc.listByEquipment(equipmentId);
            } else {
                items = uc.list();
            }

            auto jarr = Json.emptyArray;
            foreach (ref ind; items) jarr ~= indicatorToJson(ind);
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
            auto ind = uc.get_(id);
            if (ind is null) { writeError(res, 404, "Indicator not found"); return; }
            res.writeJsonBody(indicatorToJson(*ind), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            IndicatorDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.modelId = jsonStr(j, "modelId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.value_ = jsonStr(j, "value");
            dto.unit = jsonStr(j, "unit");
            dto.thresholdWarning = jsonStr(j, "thresholdWarning");
            dto.thresholdCritical = jsonStr(j, "thresholdCritical");
            dto.measuredAt = jsonStr(j, "measuredAt");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Indicator created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
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
                resp["message"] = Json("Indicator deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
