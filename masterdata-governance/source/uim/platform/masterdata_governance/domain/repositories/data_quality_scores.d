/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.repositories.data_quality_scores;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

interface DataQualityScoreRepository : ITenantRepository!(DataQualityScore, DataQualityScoreId) {

    DataQualityScore findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId);
    DataQualityScore[] findByQualityStatus(TenantId tenantId, QualityStatus status);
    DataQualityScore[] findBelowScore(TenantId tenantId, int threshold);
}
