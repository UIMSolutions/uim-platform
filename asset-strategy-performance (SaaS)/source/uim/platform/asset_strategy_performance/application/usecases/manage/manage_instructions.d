/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_instructions;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageInstructionsUseCase : UIMUseCase {
    private InstructionRepository repo;

    this(InstructionRepository repo) {
        this.repo = repo;
    }

    Instruction* get_(InstructionId id) {
        return repo.findById(id);
    }

    Instruction[] list() {
        return repo.findAll();
    }

    Instruction[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Instruction[] listByModel(ModelId modelId) {
        return repo.findByModel(modelId);
    }

    Instruction[] listByType(InstructionType instructionType) {
        return repo.findByType(instructionType);
    }

    CommandResult create(InstructionDTO dto) {
        Instruction i;
        i.id = dto.id;
        i.tenantId = dto.tenantId;
        i.modelId = dto.modelId;
        i.equipmentId = dto.equipmentId;
        i.name = dto.name;
        i.description = dto.description;
        i.version_ = dto.version_;
        i.steps = dto.steps;
        i.safetyNotes = dto.safetyNotes;
        i.requiredTools = dto.requiredTools;
        i.estimatedDuration = dto.estimatedDuration;
        i.publishedBy = dto.publishedBy;
        i.effectiveDate = dto.effectiveDate;
        i.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidInstruction(i))
            return CommandResult(false, "", "Invalid instruction data");
        repo.save(i);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(InstructionDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Instruction not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.steps.length > 0) existing.steps = dto.steps;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(InstructionId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Instruction not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
