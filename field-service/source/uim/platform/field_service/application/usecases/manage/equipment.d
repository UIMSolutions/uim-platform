/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageEquipmentUseCase { // TODO: UIMUseCase {
    private EquipmentRepository repo;

    this(EquipmentRepository repo) {
        this.repo = repo;
    }

    Equipment getEquipment(TenantId tenantId, EquipmentId id) {
        return repo.findById(tenantId, id);
    }

    Equipment[] listEquipments(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Equipment[] listEquipments(TenantId tenantId, CustomerId customerId) {
        return repo.findByCustomer(tenantId, customerId);
    }

    Equipment[] listEquipments(TenantId tenantId, EquipmentType equipmentType) {
        return repo.findByType(tenantId, equipmentType);
    }

    CommandResult createEquipment(EquipmentDTO dto) {
        Equipment e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.equipmentId;
        e.customerId = dto.customerId;
        e.serialNumber = dto.serialNumber;
        e.name = dto.name;
        e.description = dto.description;
        e.manufacturer = dto.manufacturer;
        e.model = dto.model;
        e.installationDate = dto.installationDate;
        e.warrantyEndDate = dto.warrantyEndDate;
        e.locationAddress = dto.locationAddress;
        e.latitude = dto.latitude;
        e.longitude = dto.longitude;
        e.measuringPoint = dto.measuringPoint;
        if (!FieldServiceValidator.isValidEquipment(e))
            return CommandResult(false, "", "Invalid equipment data");
        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateEquipment(EquipmentDTO dto) {
        auto equipment = repo.findById(dto.tenantId, dto.equipmentId);
        if (equipment.isNull)
            return CommandResult(false, "", "Equipment not found");
        if (dto.name.length > 0) equipment.name = dto.name;
        if (dto.description.length > 0) equipment.description = dto.description;
        if (dto.manufacturer.length > 0) equipment.manufacturer = dto.manufacturer;
        if (dto.model.length > 0) equipment.model = dto.model;
        if (dto.locationAddress.length > 0) equipment.locationAddress = dto.locationAddress;
        if (dto.lastServiceDate.length > 0) equipment.lastServiceDate = dto.lastServiceDate;
        if (dto.nextServiceDate.length > 0) equipment.nextServiceDate = dto.nextServiceDate;
        if (!dto.updatedBy.isNull) equipment.updatedBy = dto.updatedBy;
        repo.update(equipment);
        return CommandResult(true, equipment.id.value, "");
    }

    CommandResult deleteEquipment(TenantId tenantId, EquipmentId id) {
        auto equipment = repo.findById(tenantId, id);
        if (equipment.isNull)
            return CommandResult(false, "", "Equipment not found");

        repo.remove(equipment);
        return CommandResult(true, equipment.id.value, "");
    }
}
