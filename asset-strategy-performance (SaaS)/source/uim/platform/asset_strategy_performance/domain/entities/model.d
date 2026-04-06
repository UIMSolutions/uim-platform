/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.model;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Model {
    ModelId id;
    TenantId tenantId;
    string name;
    string description;
    string manufacturer;
    ModelCategory category = ModelCategory.mechanical;
    string version_;
    string modelNumber;
    string templateId;
    string isoStandard;
    bool isPublished;
    string[] supportedIndicators;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
