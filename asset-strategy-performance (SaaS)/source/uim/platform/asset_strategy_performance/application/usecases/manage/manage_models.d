/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_models;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageModelsUseCase : UIMUseCase {
    private ModelRepository repo;

    this(ModelRepository repo) {
        this.repo = repo;
    }

    Model* get_(ModelId id) {
        return repo.findById(id);
    }

    Model[] list() {
        return repo.findAll();
    }

    Model[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Model[] listByCategory(ModelCategory category) {
        return repo.findByCategory(category);
    }

    Model[] listByManufacturer(string manufacturer) {
        return repo.findByManufacturer(manufacturer);
    }

    CommandResult create(ModelDTO dto) {
        Model m;
        m.id = dto.id;
        m.tenantId = dto.tenantId;
        m.name = dto.name;
        m.description = dto.description;
        m.manufacturer = dto.manufacturer;
        m.version_ = dto.version_;
        m.modelNumber = dto.modelNumber;
        m.templateId = dto.templateId;
        m.isoStandard = dto.isoStandard;
        m.isPublished = dto.isPublished;
        m.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidModel(m))
            return CommandResult(false, "", "Invalid model data");
        repo.save(m);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ModelDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Model not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ModelId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Model not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
