/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.ports.usecases.data_quality_scores;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface IManageDataQualityScoresUseCase {

    DataQualityScore getDataQualityScore(TenantId tenantId, DataQualityScoreId id);
    DataQualityScore[] listDataQualityScores(TenantId tenantId);
    DataQualityScore getScoreByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId);
    DataQualityScore[] listByQualityStatus(TenantId tenantId, QualityStatus status);
    DataQualityScore[] listBelowThreshold(TenantId tenantId, int threshold);
    CommandResult createDataQualityScore(DataQualityScoreDTO dto);
    CommandResult updateDataQualityScore(DataQualityScoreDTO dto);
    CommandResult deleteDataQualityScore(TenantId tenantId, DataQualityScoreId id);

}
