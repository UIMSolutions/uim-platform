/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.presentation.http.controllers.assessment;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class AssessmentController : SAPController {
    private ManageAssessmentsUseCase uc;

    this(ManageAssessmentsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/asset-strategy-performance/assessments", &handleList);
        router.get("/api/v1/asset-strategy-performance/assessments/*", &handleGet);
        router.post("/api/v1/asset-strategy-performance/assessments", &handleCreate);
        router.put("/api/v1/asset-strategy-performance/assessments/*", &handleUpdate);
        router.delete_("/api/v1/asset-strategy-performance/assessments/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref a; items) jarr ~= assessmentToJson(a);
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
            auto a = uc.get_(id);
            if (a is null) { writeError(res, 404, "Assessment not found"); return; }
            res.writeJsonBody(assessmentToJson(*a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            AssessmentDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.equipmentId = jsonStr(j, "equipmentId");
            dto.modelId = jsonStr(j, "modelId");
            dto.locationId = jsonStr(j, "locationId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.assessmentType = jsonStr(j, "assessmentType");
            dto.templateId = jsonStr(j, "templateId");
            dto.score = jsonStr(j, "score");
            dto.riskLevel = jsonStr(j, "riskLevel");
            dto.likelihood = jsonStr(j, "likelihood");
            dto.consequence = jsonStr(j, "consequence");
            dto.assessedBy = jsonStr(j, "assessedBy");
            dto.approvedBy = jsonStr(j, "approvedBy");
            dto.assessmentDate = jsonStr(j, "assessmentDate");
            dto.nextReviewDate = jsonStr(j, "nextReviewDate");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Assessment created");
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
            AssessmentDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.score = jsonStr(j, "score");
            dto.riskLevel = jsonStr(j, "riskLevel");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Assessment updated");
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
                resp["message"] = Json("Assessment deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
