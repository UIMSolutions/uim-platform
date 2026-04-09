/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageEquipmentUseCase : UIMUseCase {
    private EquipmentRepository repo;

    this(EquipmentRepository repo) {
        this.repo = repo;
    }

    Equipment* get_(EquipmentId id) {
        return repo.findById(id);
    }

    Equipment[] list() {
        return repo.findAll();
    }

    Equipment[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Equipment[] listByCustomer(CustomerId customerId) {
        return repo.findByCustomer(customerId);
    }

    Equipment[] listByType(EquipmentType equipmentType) {
        return repo.findByType(equipmentType);
    }

    CommandResult create(EquipmentDTO dto) {
        Equipment e;
        e.id = dto.id;
        e.tenantId = dto.tenantId;
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
        e.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidEquipment(e))
            return CommandResult(false, "", "Invalid equipment data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(EquipmentDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Equipment not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.manufacturer.length > 0) existing.manufacturer = dto.manufacturer;
        if (dto.model.length > 0) existing.model = dto.model;
        if (dto.locationAddress.length > 0) existing.locationAddress = dto.locationAddress;
        if (dto.lastServiceDate.length > 0) existing.lastServiceDate = dto.lastServiceDate;
        if (dto.nextServiceDate.length > 0) existing.nextServiceDate = dto.nextServiceDate;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(EquipmentId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Equipment not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
