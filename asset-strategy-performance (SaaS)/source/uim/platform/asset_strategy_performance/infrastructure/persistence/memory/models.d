/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.persistence.memory.models;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class MemoryModelRepository : ModelRepository {
    private Model[] store;

    Model[] findAll() { return store; }

    Model* findById(ModelId id) {
        foreach (ref m; store)
            if (m.id == id) return &m;
        return null;
    }

    Model[] findByTenant(TenantId tenantId) {
        Model[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId) result ~= m;
        return result;
    }

    Model[] findByCategory(ModelCategory category) {
        Model[] result;
        foreach (ref m; store)
            if (m.category == category) result ~= m;
        return result;
    }

    Model[] findByManufacturer(string manufacturer) {
        Model[] result;
        foreach (ref m; store)
            if (m.manufacturer == manufacturer) result ~= m;
        return result;
    }

    void save(Model model) { store ~= model; }

    void update(Model model) {
        foreach (ref m; store)
            if (m.id == model.id) { m = model; return; }
    }

    void remove(ModelId id) {
        import std.algorithm : remove;
        store = store.remove!(m => m.id == id);
    }
}
