/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.specification;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Specification {
    SpecificationId id;
    TenantId tenantId;
    string productId;
    string name;
    string description;
    SpecificationType specificationType = SpecificationType.functional;
    SpecificationStatus status = SpecificationStatus.draft;
    string version_;
    string specificationNumber;
    string property;
    string targetValue;
    string unit;
    string lowerLimit;
    string upperLimit;
    string testMethod;
    string complianceStandard;
    string approvedBy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
