/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_spare_parts;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class ManageSparePartsUseCase : UIMUseCase {
    private SparePartRepository repo;

    this(SparePartRepository repo) {
        this.repo = repo;
    }

    SparePart* get_(SparePartId id) {
        return repo.findById(id);
    }

    SparePart[] list() {
        return repo.findAll();
    }

    SparePart[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SparePart[] listByModel(string modelId) {
        return repo.findByModel(modelId);
    }

    SparePart[] listByPartNumber(string partNumber) {
        return repo.findByPartNumber(partNumber);
    }

    SparePart[] listByManufacturer(string manufacturer) {
        return repo.findByManufacturer(manufacturer);
    }

    CommandResult create(SparePartDTO dto) {
        SparePart sp;
        sp.id = dto.id;
        sp.tenantId = dto.tenantId;
        sp.modelId = dto.modelId;
        sp.equipmentId = dto.equipmentId;
        sp.partNumber = dto.partNumber;
        sp.name = dto.name;
        sp.description = dto.description;
        sp.manufacturer = dto.manufacturer;
        sp.category = dto.category;
        sp.quantity = dto.quantity;
        sp.unit = dto.unit;
        sp.leadTimeDays = dto.leadTimeDays;
        sp.isCritical = dto.isCritical;
        sp.createdBy = dto.createdBy;
        if (!AssetValidator.isValidSparePart(sp))
            return CommandResult(false, "", "Invalid spare part data");
        repo.save(sp);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(SparePartDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Spare part not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.manufacturer.length > 0) existing.manufacturer = dto.manufacturer;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(SparePartId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Spare part not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
