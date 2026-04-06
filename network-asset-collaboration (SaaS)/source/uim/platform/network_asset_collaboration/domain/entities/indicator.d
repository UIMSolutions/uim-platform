/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.indicator;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct Indicator {
    IndicatorId id;
    TenantId tenantId;
    string equipmentId;
    string modelId;
    string name;
    string description;
    IndicatorType indicatorType = IndicatorType.custom;
    IndicatorStatus status = IndicatorStatus.unknown;
    string value_;
    string unit;
    string thresholdWarning;
    string thresholdCritical;
    string measuredAt;
    string createdBy;
    string createdAt;
    string modifiedAt;
}
