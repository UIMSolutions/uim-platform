/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.assessment;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Assessment {
    AssessmentId id;
    TenantId tenantId;
    string equipmentId;
    string modelId;
    string locationId;
    string name;
    string description;
    AssessmentType assessmentType = AssessmentType.riskCriticality;
    AssessmentStatus status = AssessmentStatus.draft;
    string templateId;
    string score;
    string riskLevel;
    string likelihood;
    string consequence;
    string assessedBy;
    string approvedBy;
    string assessmentDate;
    string nextReviewDate;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
