/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.bill_of_material;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct BillOfMaterial {
    BillOfMaterialId id;
    TenantId tenantId;
    string productId;
    string name;
    string description;
    BomType bomType = BomType.engineering;
    string version_;
    string usage;
    string plant;
    string validFrom;
    string validTo;
    string baseQuantity;
    string baseUnit;
    bool isActive;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}

struct BomItem {
    string itemId;
    string bomId;
    string componentId;
    string componentName;
    BomItemType itemType = BomItemType.component;
    string quantity;
    string unit;
    string position;
    string sortOrder;
    bool isAlternate;
    string alternateGroup;
}
