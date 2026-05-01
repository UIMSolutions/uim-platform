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
    UserId createdBy;
    UserId updatedBy;
    string createdAt;
    string updatedAt;

    Json toJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("customerId", customerId)
            .set("serialNumber", serialNumber)
            .set("name", name)
            .set("description", description)
            .set("equipmentType", equipmentType.to!string)
            .set("status", status.to!string)
            .set("manufacturer", manufacturer)
            .set("model", model)
            .set("installationDate", installationDate)
            .set("warrantyEndDate", warrantyEndDate)
            .set("locationAddress", locationAddress)
            .set("latitude", latitude)
            .set("longitude", longitude)
            .set("lastServiceDate", lastServiceDate)
            .set("nextServiceDate", nextServiceDate)
            .set("measuringPoint", measuringPoint)
            .set("createdBy", createdBy)
            .set("updatedBy", updatedBy)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt);
    }
}
