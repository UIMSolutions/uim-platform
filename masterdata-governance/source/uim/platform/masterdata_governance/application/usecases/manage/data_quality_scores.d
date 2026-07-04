/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.usecases.manage.data_quality_scores;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class ManageDataQualityScoresUseCase {
    private DataQualityScoreRepository repo;

    this(DataQualityScoreRepository repo) {
        this.repo = repo;
    }

    DataQualityScore getDataQualityScore(TenantId tenantId, DataQualityScoreId id) {
        return repo.findById(tenantId, id);
    }

    DataQualityScore[] listDataQualityScores(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataQualityScore getScoreByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        return repo.findByBusinessPartner(tenantId, bpId);
    }

    DataQualityScore[] listByQualityStatus(TenantId tenantId, QualityStatus status) {
        return repo.findByQualityStatus(tenantId, status);
    }

    DataQualityScore[] listBelowThreshold(TenantId tenantId, int threshold) {
        return repo.findBelowScore(tenantId, threshold);
    }

    CommandResult createDataQualityScore(DataQualityScoreDTO dto) {
        auto score = DataQualityScore(dto.tenantId); //, UserId("test-user"));
        score.id = dto.scoreId;
        score.businessPartnerId = dto.businessPartnerId;
        score.overallScore = dto.overallScore;
        score.completenessScore = dto.completenessScore;
        score.consistencyScore = dto.consistencyScore;
        score.accuracyScore = dto.accuracyScore;
        score.uniquenessScore = dto.uniquenessScore;
        score.evaluationDetails = dto.evaluationDetails;

        if (score.overallScore >= 90) score.qualityStatus = QualityStatus.excellent;
        else if (score.overallScore >= 70) score.qualityStatus = QualityStatus.good;
        else if (score.overallScore >= 50) score.qualityStatus = QualityStatus.fair;
        else score.qualityStatus = QualityStatus.poor;

        if (!MasterdataGovernanceValidator.isValidDataQualityScore(score))
            return CommandResult(false, "", "Invalid data quality score data");

        repo.save(score);
        return CommandResult(true, score.id.value, "");
    }

    CommandResult updateDataQualityScore(DataQualityScoreDTO dto) {
        auto score = repo.findById(dto.tenantId, dto.scoreId);
        if (score.isNull)
            return CommandResult(false, "", "Data quality score not found");

        score.overallScore = dto.overallScore;
        score.completenessScore = dto.completenessScore;
        score.consistencyScore = dto.consistencyScore;
        score.accuracyScore = dto.accuracyScore;
        score.uniquenessScore = dto.uniquenessScore;
        if (dto.evaluationDetails.length > 0) score.evaluationDetails = dto.evaluationDetails;
        if (!dto.updatedBy.isNull) score.updatedBy = dto.updatedBy;

        if (score.overallScore >= 90) score.qualityStatus = QualityStatus.excellent;
        else if (score.overallScore >= 70) score.qualityStatus = QualityStatus.good;
        else if (score.overallScore >= 50) score.qualityStatus = QualityStatus.fair;
        else score.qualityStatus = QualityStatus.poor;

        repo.update(score);
        return CommandResult(true, score.id.value, "");
    }

    CommandResult deleteDataQualityScore(TenantId tenantId, DataQualityScoreId id) {
        auto score = repo.findById(tenantId, id);
        if (score.isNull)
            return CommandResult(false, "", "Data quality score not found");

        repo.remove(score);
        return CommandResult(true, score.id.value, "");
    }
}
