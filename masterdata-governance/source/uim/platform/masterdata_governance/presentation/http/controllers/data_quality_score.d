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
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Data quality scores list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataQualityScoreId(precheck.id);
        auto score = usecase.getDataQualityScore(tenantId, id);
        if (score.isNull)
            return errorResponse("Data quality score not found", 404);

        auto responseData = score.toJson();
        return successResponse("Data quality score retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        DataQualityScoreDTO dto;
        dto.tenantId = tenantId;
        dto.businessPartnerId = BusinessPartnerId(data.getString("businessPartnerId"));
        dto.overallScore = data.getInteger("overallScore");
        dto.completenessScore = data.getInteger("completenessScore");
        dto.consistencyScore = data.getInteger("consistencyScore");
        dto.accuracyScore = data.getInteger("accuracyScore");
        dto.uniquenessScore = data.getInteger("uniquenessScore");
        dto.evaluationDetails = data.getString("evaluationDetails");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataQualityScore(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data quality score created");
        return successResponse("Data quality score created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataQualityScoreId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data quality score ID", 400);

        autodata = precheck.data;
        DataQualityScoreDTO dto;
        dto.scoreId = DataQualityScoreId(precheck.id);
        dto.tenantId = tenantId;
        dto.overallScore = data.getInteger("overallScore");
        dto.completenessScore = data.getInteger("completenessScore");
        dto.consistencyScore = data.getInteger("consistencyScore");
        dto.accuracyScore = data.getInteger("accuracyScore");
        dto.uniquenessScore = data.getInteger("uniquenessScore");
        dto.evaluationDetails = data.getString("evaluationDetails");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDataQualityScore(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", id);
        return successResponse("Data quality score updated successfully", "Updated", 200, responseData);

    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataQualityScoreId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data quality score ID", 400);

        auto result = usecase.deleteDataQualityScore(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject
            .set("id", id);
        return successResponse("Data quality score deleted successfully", "Deleted", 200, responseData);
    }
}
