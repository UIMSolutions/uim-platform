/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_functions;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageFunctionsUseCase : UIMUseCase {
    private FunctionRepository repo;

    this(FunctionRepository repo) {
        this.repo = repo;
    }

    Function* get_(FunctionId id) {
        return repo.findById(id);
    }

    Function[] list() {
        return repo.findAll();
    }

    Function[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Function[] listByEquipment(EquipmentId equipmentId) {
        return repo.findByEquipment(equipmentId);
    }

    Function[] listByStatus(FunctionStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(FunctionDTO dto) {
        Function f;
        f.id = dto.id;
        f.tenantId = dto.tenantId;
        f.equipmentId = dto.equipmentId;
        f.modelId = dto.modelId;
        f.locationId = dto.locationId;
        f.name = dto.name;
        f.description = dto.description;
        f.operatingContext = dto.operatingContext;
        f.performanceStandard = dto.performanceStandard;
        f.failureDefinition = dto.failureDefinition;
        f.redundancy = dto.redundancy;
        f.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidFunction(f))
            return CommandResult(false, "", "Invalid function data");
        repo.save(f);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(FunctionDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Function not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.performanceStandard.length > 0) existing.performanceStandard = dto.performanceStandard;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(FunctionId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Function not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
