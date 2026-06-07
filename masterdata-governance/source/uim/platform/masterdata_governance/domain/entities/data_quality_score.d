/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.entities.data_quality_score;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

struct DataQualityScore {
    mixin TenantEntity!(DataQualityScoreId);

    BusinessPartnerId businessPartnerId;
    int overallScore;
    int completenessScore;
    int consistencyScore;
    int accuracyScore;
    int uniquenessScore;
    QualityStatus qualityStatus = QualityStatus.fair;
    long lastEvaluatedAt;
    string evaluationDetails;
    string failedRules;
    string passedRules;
    int totalRulesChecked;
    int failedRulesCount;

    Json toJson() const {
        return entityToJson
            .set("businessPartnerId", businessPartnerId.value)
            .set("overallScore", overallScore)
            .set("completenessScore", completenessScore)
            .set("consistencyScore", consistencyScore)
            .set("accuracyScore", accuracyScore)
            .set("uniquenessScore", uniquenessScore)
            .set("qualityStatus", qualityStatus.to!string)
            .set("lastEvaluatedAt", lastEvaluatedAt)
            .set("evaluationDetails", evaluationDetails)
            .set("failedRules", failedRules)
            .set("passedRules", passedRules)
            .set("totalRulesChecked", totalRulesChecked)
            .set("failedRulesCount", failedRulesCount);
    }
}
