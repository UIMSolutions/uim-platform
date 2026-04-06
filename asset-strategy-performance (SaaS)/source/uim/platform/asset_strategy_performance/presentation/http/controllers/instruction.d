/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.presentation.http.controllers.instruction;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class InstructionController : SAPController {
    private ManageInstructionsUseCase uc;

    this(ManageInstructionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/asset-strategy-performance/instructions", &handleList);
        router.get("/api/v1/asset-strategy-performance/instructions/*", &handleGet);
        router.post("/api/v1/asset-strategy-performance/instructions", &handleCreate);
        router.put("/api/v1/asset-strategy-performance/instructions/*", &handleUpdate);
        router.delete_("/api/v1/asset-strategy-performance/instructions/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref i; items) jarr ~= instructionToJson(i);
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
            auto i = uc.get_(id);
            if (i is null) { writeError(res, 404, "Instruction not found"); return; }
            res.writeJsonBody(instructionToJson(*i), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            InstructionDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.modelId = jsonStr(j, "modelId");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.instructionType = jsonStr(j, "instructionType");
            dto.priority = jsonStr(j, "priority");
            dto.version_ = jsonStr(j, "version");
            dto.steps = jsonStr(j, "steps");
            dto.safetyNotes = jsonStr(j, "safetyNotes");
            dto.requiredTools = jsonStr(j, "requiredTools");
            dto.estimatedDuration = jsonStr(j, "estimatedDuration");
            dto.publishedBy = jsonStr(j, "publishedBy");
            dto.effectiveDate = jsonStr(j, "effectiveDate");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Instruction created");
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
            InstructionDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.steps = jsonStr(j, "steps");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Instruction updated");
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
                resp["message"] = Json("Instruction deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
