/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.indicators;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryIndicatorRepository : IndicatorRepository {
    private Indicator[] store;

    Indicator[] findAll() { return store; }

    Indicator* findById(IndicatorId id) {
        foreach (ref ind; store)
            if (ind.id == id) return &ind;
        return null;
    }

    Indicator[] findByTenant(TenantId tenantId) {
        Indicator[] result;
        foreach (ref ind; store)
            if (ind.tenantId == tenantId) result ~= ind;
        return result;
    }

    Indicator[] findByEquipment(string equipmentId) {
        Indicator[] result;
        foreach (ref ind; store)
            if (ind.equipmentId == equipmentId) result ~= ind;
        return result;
    }

    Indicator[] findByType(IndicatorType indicatorType) {
        Indicator[] result;
        foreach (ref ind; store)
            if (ind.indicatorType == indicatorType) result ~= ind;
        return result;
    }

    Indicator[] findByStatus(IndicatorStatus status) {
        Indicator[] result;
        foreach (ref ind; store)
            if (ind.status == status) result ~= ind;
        return result;
    }

    void save(Indicator indicator) { store ~= indicator; }

    void remove(IndicatorId id) {
        import std.algorithm : remove;
        store = store.remove!(ind => ind.id == id);
    }
}
