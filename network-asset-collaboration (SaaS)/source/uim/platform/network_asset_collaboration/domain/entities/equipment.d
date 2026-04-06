/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.equipment;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct Equipment {
    EquipmentId id;
    TenantId tenantId;
    ModelId modelId;
    string serialNumber;
    string name;
    string description;
    EquipmentStatus status = EquipmentStatus.active;
    string manufacturer;
    string operatorCompanyId;
    string location;
    string latitude;
    string longitude;
    string installationDate;
    string commissioningDate;
    string warrantyEndDate;
    string batchNumber;
    string firmwareVersion;
    string[] externalIds;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
