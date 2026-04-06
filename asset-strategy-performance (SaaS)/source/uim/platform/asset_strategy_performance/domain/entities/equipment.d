/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.equipment;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Equipment {
    EquipmentId id;
    TenantId tenantId;
    ModelId modelId;
    LocationId locationId;
    string serialNumber;
    string name;
    string description;
    EquipmentStatus status = EquipmentStatus.active;
    string manufacturer;
    string operatorId;
    string installationDate;
    string commissioningDate;
    string warrantyEndDate;
    string criticality;
    string maintenanceStrategy;
    string lastMaintenanceDate;
    string nextMaintenanceDate;
    string firmwareVersion;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
