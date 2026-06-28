/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.persistence.memory.data_quality_scores;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class MemoryDataQualityScoreRepository
    : TenantRepository!(DataQualityScore, DataQualityScoreId), DataQualityScoreRepository {

    DataQualityScore findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        auto all = find(tenantId);
        foreach (score; all)
            if (score.businessPartnerId.value == bpId.value) return score;
        return DataQualityScore.init;
    }

    DataQualityScore[] findByQualityStatus(TenantId tenantId, QualityStatus status) {
        return find(tenantId).filter!(e => e.qualityStatus == status).array;
    }

    DataQualityScore[] findBelowScore(TenantId tenantId, int threshold) {
        return find(tenantId).filter!(e => e.overallScore < threshold).array;
    }
}
