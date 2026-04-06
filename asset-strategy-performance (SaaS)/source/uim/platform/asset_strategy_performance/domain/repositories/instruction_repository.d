/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.repositories.instruction_repository;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

interface InstructionRepository {
    Instruction[] findAll();
    Instruction* findById(InstructionId id);
    Instruction[] findByTenant(TenantId tenantId);
    Instruction[] findByModel(ModelId modelId);
    Instruction[] findByType(InstructionType instructionType);
    void save(Instruction instruction);
    void update(Instruction instruction);
    void remove(InstructionId id);
}
