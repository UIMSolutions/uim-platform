/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.persistence.memory.instructions;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class MemoryInstructionRepository : InstructionRepository {
    private Instruction[] store;

    Instruction[] findAll() { return store; }

    Instruction* findById(InstructionId id) {
        foreach (ref i; store)
            if (i.id == id) return &i;
        return null;
    }

    Instruction[] findByTenant(TenantId tenantId) {
        Instruction[] result;
        foreach (ref i; store)
            if (i.tenantId == tenantId) result ~= i;
        return result;
    }

    Instruction[] findByModel(ModelId modelId) {
        Instruction[] result;
        foreach (ref i; store)
            if (i.modelId == modelId) result ~= i;
        return result;
    }

    Instruction[] findByType(InstructionType instructionType) {
        Instruction[] result;
        foreach (ref i; store)
            if (i.instructionType == instructionType) result ~= i;
        return result;
    }

    void save(Instruction instruction) { store ~= instruction; }

    void update(Instruction instruction) {
        foreach (ref i; store)
            if (i.id == instruction.id) { i = instruction; return; }
    }

    void remove(InstructionId id) {
        import std.algorithm : remove;
        store = store.remove!(i => i.id == id);
    }
}
