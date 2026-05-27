/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.data_quality_score;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class DataQualityScoreController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityScoreId(precheck.id);
            auto score = usecase.getDataQualityScore(tenantId, id);
            if (score.isNull) { writeError(res, 404, "Data quality score not found"); return; }
            res.writeJsonBody(score.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DataQualityScoreDTO dto;
            dto.scoreId = DataQualityScoreId(precheck.id);
            dto.tenantId = tenantId;
            dto.businessPartnerId = BusinessPartnerId(j.getString("businessPartnerId"));
            dto.overallScore = j.getInteger("overallScore");
            dto.completenessScore = j.getInteger("completenessScore");
            dto.consistencyScore = j.getInteger("consistencyScore");
            dto.accuracyScore = j.getInteger("accuracyScore");
            dto.uniquenessScore = j.getInteger("uniquenessScore");
            dto.evaluationDetails = j.getString("evaluationDetails");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDataQualityScore(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality score created"), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            DataQualityScoreDTO dto;
            dto.scoreId = DataQualityScoreId(precheck.id);
            dto.tenantId = tenantId;
            dto.overallScore = j.getInteger("overallScore");
            dto.completenessScore = j.getInteger("completenessScore");
            dto.consistencyScore = j.getInteger("consistencyScore");
            dto.accuracyScore = j.getInteger("accuracyScore");
            dto.uniquenessScore = j.getInteger("uniquenessScore");
            dto.evaluationDetails = j.getString("evaluationDetails");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDataQualityScore(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data quality score updated"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DataQualityScoreId(precheck.id);
            auto result = usecase.deleteDataQualityScore(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("message", "Data quality score deleted"), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
