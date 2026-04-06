/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.product_structure;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct ProductStructure {
    ProductStructureId id;
    TenantId tenantId;
    string productId;
    string name;
    string description;
    StructureNodeType nodeType = StructureNodeType.product;
    string parentNodeId;
    string position;
    string sortOrder;
    string quantity;
    string unit;
    string variantCondition;
    string configurationProfile;
    bool isMandatory;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
