/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_products;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageProductsUseCase : UIMUseCase {
    private ProductRepository repo;

    this(ProductRepository repo) {
        this.repo = repo;
    }

    Product* get_(ProductId id) {
        return repo.findById(id);
    }

    Product[] list() {
        return repo.findAll();
    }

    Product[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Product[] listByType(ProductType productType) {
        return repo.findByType(productType);
    }

    Product[] listByStatus(ProductStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(ProductDTO dto) {
        Product p;
        p.id = dto.id;
        p.tenantId = dto.tenantId;
        p.name = dto.name;
        p.description = dto.description;
        p.version_ = dto.version_;
        p.productNumber = dto.productNumber;
        p.manufacturer = dto.manufacturer;
        p.category = dto.category;
        p.baseUnit = dto.baseUnit;
        p.weight = dto.weight;
        p.weightUnit = dto.weightUnit;
        p.validFrom = dto.validFrom;
        p.validTo = dto.validTo;
        p.createdBy = dto.createdBy;
        if (!ProductValidator.isValidProduct(p))
            return CommandResult(false, "", "Invalid product data");
        repo.save(p);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ProductDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Product not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.manufacturer.length > 0) existing.manufacturer = dto.manufacturer;
        if (dto.category.length > 0) existing.category = dto.category;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ProductId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Product not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
