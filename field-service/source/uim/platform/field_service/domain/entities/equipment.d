/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Equipment {
    EquipmentId id;
    TenantId tenantId;
    CustomerId customerId;
    string serialNumber;
    string name;
    string description;
    EquipmentType equipmentType = EquipmentType.machine;
    EquipmentStatus status = EquipmentStatus.active;
    string manufacturer;
    string model;
    string installationDate;
    string warrantyEndDate;
    string locationAddress;
    string latitude;
    string longitude;
    string lastServiceDate;
    string nextServiceDate;
    string measuringPoint;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
