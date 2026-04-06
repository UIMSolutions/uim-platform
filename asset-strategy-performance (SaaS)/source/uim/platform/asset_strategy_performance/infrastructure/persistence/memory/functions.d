/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.persistence.memory.functions;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class MemoryFunctionRepository : FunctionRepository {
    private Function[] store;

    Function[] findAll() { return store; }

    Function* findById(FunctionId id) {
        foreach (ref f; store)
            if (f.id == id) return &f;
        return null;
    }

    Function[] findByTenant(TenantId tenantId) {
        Function[] result;
        foreach (ref f; store)
            if (f.tenantId == tenantId) result ~= f;
        return result;
    }

    Function[] findByEquipment(EquipmentId equipmentId) {
        Function[] result;
        foreach (ref f; store)
            if (f.equipmentId == equipmentId) result ~= f;
        return result;
    }

    Function[] findByStatus(FunctionStatus status) {
        Function[] result;
        foreach (ref f; store)
            if (f.status == status) result ~= f;
        return result;
    }

    void save(Function func) { store ~= func; }

    void update(Function func) {
        foreach (ref f; store)
            if (f.id == func.id) { f = func; return; }
    }

    void remove(FunctionId id) {
        import std.algorithm : remove;
        store = store.remove!(f => f.id == id);
    }
}
