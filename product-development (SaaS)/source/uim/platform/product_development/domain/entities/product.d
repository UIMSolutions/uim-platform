/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.product;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Product {
    ProductId id;
    TenantId tenantId;
    string name;
    string description;
    ProductType productType = ProductType.discrete;
    ProductStatus status = ProductStatus.draft;
    LifecyclePhase lifecyclePhase = LifecyclePhase.concept;
    string version_;
    string productNumber;
    string manufacturer;
    string category;
    string baseUnit;
    string weight;
    string weightUnit;
    string validFrom;
    string validTo;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
