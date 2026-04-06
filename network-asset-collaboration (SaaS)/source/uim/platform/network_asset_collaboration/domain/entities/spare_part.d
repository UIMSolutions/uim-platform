/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.spare_part;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct SparePart {
    SparePartId id;
    TenantId tenantId;
    string modelId;
    string equipmentId;
    string partNumber;
    string name;
    string description;
    string manufacturer;
    string category;
    long quantity;
    string unit;
    string leadTimeDays;
    bool isCritical;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
