/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_boms;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageBomsUseCase : UIMUseCase {
    private BillOfMaterialRepository repo;

    this(BillOfMaterialRepository repo) {
        this.repo = repo;
    }

    BillOfMaterial* get_(BillOfMaterialId id) {
        return repo.findById(id);
    }

    BillOfMaterial[] list() {
        return repo.findAll();
    }

    BillOfMaterial[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    CommandResult create(BillOfMaterialDTO dto) {
        BillOfMaterial b;
        b.id = dto.id;
        b.tenantId = dto.tenantId;
        b.productId = dto.productId;
        b.name = dto.name;
        b.description = dto.description;
        b.version_ = dto.version_;
        b.usage = dto.usage;
        b.plant = dto.plant;
        b.validFrom = dto.validFrom;
        b.validTo = dto.validTo;
        b.baseQuantity = dto.baseQuantity;
        b.baseUnit = dto.baseUnit;
        b.isActive = dto.isActive;
        b.createdBy = dto.createdBy;
        if (!ProductValidator.isValidBom(b))
            return CommandResult(false, "", "Invalid BOM data");
        repo.save(b);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(BillOfMaterialDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "BOM not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.plant.length > 0) existing.plant = dto.plant;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(BillOfMaterialId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "BOM not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
