/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_product_structures;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageProductStructuresUseCase : UIMUseCase {
    private ProductStructureRepository repo;

    this(ProductStructureRepository repo) {
        this.repo = repo;
    }

    ProductStructure* get_(ProductStructureId id) {
        return repo.findById(id);
    }

    ProductStructure[] list() {
        return repo.findAll();
    }

    ProductStructure[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    ProductStructure[] listByParent(string parentNodeId) {
        return repo.findByParent(parentNodeId);
    }

    CommandResult create(ProductStructureDTO dto) {
        ProductStructure ps;
        ps.id = dto.id;
        ps.tenantId = dto.tenantId;
        ps.productId = dto.productId;
        ps.name = dto.name;
        ps.description = dto.description;
        ps.parentNodeId = dto.parentNodeId;
        ps.position = dto.position;
        ps.sortOrder = dto.sortOrder;
        ps.quantity = dto.quantity;
        ps.unit = dto.unit;
        ps.variantCondition = dto.variantCondition;
        ps.configurationProfile = dto.configurationProfile;
        ps.isMandatory = dto.isMandatory;
        ps.createdBy = dto.createdBy;
        if (!ProductValidator.isValidProductStructure(ps))
            return CommandResult(false, "", "Invalid product structure data");
        repo.save(ps);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ProductStructureDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Product structure not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.position.length > 0) existing.position = dto.position;
        if (dto.quantity.length > 0) existing.quantity = dto.quantity;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ProductStructureId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Product structure not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
