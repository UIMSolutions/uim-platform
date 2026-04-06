/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_equipment;

import uim.platform.network_asset_collaboration;

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

    Equipment[] listByModel(ModelId modelId) {
        return repo.findByModel(modelId);
    }

    Equipment[] listByStatus(EquipmentStatus status) {
        return repo.findByStatus(status);
    }

    Equipment[] listByManufacturer(string manufacturer) {
        return repo.findByManufacturer(manufacturer);
    }

    CommandResult create(EquipmentDTO dto) {
        Equipment e;
        e.id = dto.id;
        e.tenantId = dto.tenantId;
        e.modelId = dto.modelId;
        e.serialNumber = dto.serialNumber;
        e.name = dto.name;
        e.description = dto.description;
        e.manufacturer = dto.manufacturer;
        e.operatorCompanyId = dto.operatorCompanyId;
        e.location = dto.location;
        e.latitude = dto.latitude;
        e.longitude = dto.longitude;
        e.installationDate = dto.installationDate;
        e.commissioningDate = dto.commissioningDate;
        e.warrantyEndDate = dto.warrantyEndDate;
        e.batchNumber = dto.batchNumber;
        e.firmwareVersion = dto.firmwareVersion;
        e.createdBy = dto.createdBy;
        if (!AssetValidator.isValidEquipment(e))
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
        if (dto.location.length > 0) existing.location = dto.location;
        if (dto.firmwareVersion.length > 0) existing.firmwareVersion = dto.firmwareVersion;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(EquipmentId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Equipment not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
