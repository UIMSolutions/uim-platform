/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.failure_mode;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct FailureMode {
    FailureModeId id;
    TenantId tenantId;
    ModelId modelId;
    string equipmentId;
    string name;
    string description;
    FailureSeverity severity = FailureSeverity.minor;
    FailureCategory category = FailureCategory.mechanical;
    string cause;
    string effect;
    string detection;
    string mitigation;
    string riskPriorityNumber;
    string occurrenceProbability;
    string detectability;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
