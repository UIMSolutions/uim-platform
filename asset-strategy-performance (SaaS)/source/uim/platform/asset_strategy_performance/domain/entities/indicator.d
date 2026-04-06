/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.indicator;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Indicator {
    IndicatorId id;
    TenantId tenantId;
    string equipmentId;
    string modelId;
    string name;
    string description;
    IndicatorType indicatorType = IndicatorType.temperature;
    IndicatorStatus status = IndicatorStatus.normal;
    string value_;
    string unit;
    string thresholdWarning;
    string thresholdCritical;
    string measuredAt;
    string createdBy;
    string createdAt;
    string modifiedAt;
}
