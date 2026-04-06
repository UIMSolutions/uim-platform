/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_specifications;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageSpecificationsUseCase : UIMUseCase {
    private SpecificationRepository repo;

    this(SpecificationRepository repo) {
        this.repo = repo;
    }

    Specification* get_(SpecificationId id) {
        return repo.findById(id);
    }

    Specification[] list() {
        return repo.findAll();
    }

    Specification[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    CommandResult create(SpecificationDTO dto) {
        Specification s;
        s.id = dto.id;
        s.tenantId = dto.tenantId;
        s.productId = dto.productId;
        s.name = dto.name;
        s.description = dto.description;
        s.version_ = dto.version_;
        s.specificationNumber = dto.specificationNumber;
        s.property = dto.property;
        s.targetValue = dto.targetValue;
        s.unit = dto.unit;
        s.lowerLimit = dto.lowerLimit;
        s.upperLimit = dto.upperLimit;
        s.testMethod = dto.testMethod;
        s.complianceStandard = dto.complianceStandard;
        s.approvedBy = dto.approvedBy;
        s.createdBy = dto.createdBy;
        if (!ProductValidator.isValidSpecification(s))
            return CommandResult(false, "", "Invalid specification data");
        repo.save(s);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(SpecificationDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Specification not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.targetValue.length > 0) existing.targetValue = dto.targetValue;
        if (dto.testMethod.length > 0) existing.testMethod = dto.testMethod;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(SpecificationId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Specification not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
