/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.data_quality_score;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class DataQualityScoreController : PlatformController {
    private ManageDataQualityScoresUseCase usecase;

    this(ManageDataQualityScoresUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/masterdata-governance/data-quality-scores", &handleList);
        router.get("/api/v1/masterdata-governance/data-quality-scores/*", &handleGet);
        router.post("/api/v1/masterdata-governance/data-quality-scores", &handleCreate);
        router.put("/api/v1/masterdata-governance/data-quality-scores/*", &handleUpdate);
        router.delete_("/api/v1/masterdata-governance/data-quality-scores/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listDataQualityScores(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityScoreId(extractIdFromPath(path));
            auto score = usecase.getDataQualityScore(tenantId, id);
            if (score.isNull) { writeError(res, 404, "Data quality score not found"); return; }
            res.writeJsonBody(score.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DataQualityScoreDTO dto;
            dto.scoreId = DataQualityScoreId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.businessPartnerId = BusinessPartnerId(j.getString("businessPartnerId"));
            dto.overallScore = j.getInt("overallScore");
            dto.completenessScore = j.getInt("completenessScore");
            dto.consistencyScore = j.getInt("consistencyScore");
            dto.accuracyScore = j.getInt("accuracyScore");
            dto.uniquenessScore = j.getInt("uniquenessScore");
            dto.evaluationDetails = j.getString("evaluationDetails");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDataQualityScore(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality score created"), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DataQualityScoreDTO dto;
            dto.scoreId = DataQualityScoreId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.overallScore = j.getInt("overallScore");
            dto.completenessScore = j.getInt("completenessScore");
            dto.consistencyScore = j.getInt("consistencyScore");
            dto.accuracyScore = j.getInt("accuracyScore");
            dto.uniquenessScore = j.getInt("uniquenessScore");
            dto.evaluationDetails = j.getString("evaluationDetails");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDataQualityScore(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality score updated"), 200);
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
            auto id = DataQualityScoreId(extractIdFromPath(path));
            auto result = usecase.deleteDataQualityScore(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "Data quality score deleted"), 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
