/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.function_;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Function {
    FunctionId id;
    TenantId tenantId;
    string equipmentId;
    string modelId;
    string locationId;
    string name;
    string description;
    FunctionStatus status = FunctionStatus.operational;
    string operatingContext;
    string performanceStandard;
    string failureDefinition;
    string redundancy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
