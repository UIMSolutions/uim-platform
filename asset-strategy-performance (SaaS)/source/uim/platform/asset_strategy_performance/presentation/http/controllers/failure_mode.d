/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.presentation.http.controllers.failure_mode;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class FailureModeController : SAPController {
    private ManageFailureModesUseCase uc;

    this(ManageFailureModesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/asset-strategy-performance/failure-modes", &handleList);
        router.get("/api/v1/asset-strategy-performance/failure-modes/*", &handleGet);
        router.post("/api/v1/asset-strategy-performance/failure-modes", &handleCreate);
        router.put("/api/v1/asset-strategy-performance/failure-modes/*", &handleUpdate);
        router.delete_("/api/v1/asset-strategy-performance/failure-modes/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref fm; items) jarr ~= failureModeToJson(fm);
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
            auto fm = uc.get_(id);
            if (fm is null) { writeError(res, 404, "Failure mode not found"); return; }
            res.writeJsonBody(failureModeToJson(*fm), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            FailureModeDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.modelId = jsonStr(j, "modelId");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.severity = jsonStr(j, "severity");
            dto.category = jsonStr(j, "category");
            dto.cause = jsonStr(j, "cause");
            dto.effect = jsonStr(j, "effect");
            dto.detection = jsonStr(j, "detection");
            dto.mitigation = jsonStr(j, "mitigation");
            dto.riskPriorityNumber = jsonStr(j, "riskPriorityNumber");
            dto.occurrenceProbability = jsonStr(j, "occurrenceProbability");
            dto.detectability = jsonStr(j, "detectability");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Failure mode created");
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
            FailureModeDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.mitigation = jsonStr(j, "mitigation");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Failure mode updated");
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
                resp["message"] = Json("Failure mode deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
