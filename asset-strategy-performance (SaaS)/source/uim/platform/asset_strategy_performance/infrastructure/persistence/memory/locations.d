/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.persistence.memory.locations;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class MemoryLocationRepository : LocationRepository {
    private Location[] store;

    Location[] findAll() { return store; }

    Location* findById(LocationId id) {
        foreach (ref l; store)
            if (l.id == id) return &l;
        return null;
    }

    Location[] findByTenant(TenantId tenantId) {
        Location[] result;
        foreach (ref l; store)
            if (l.tenantId == tenantId) result ~= l;
        return result;
    }

    Location[] findByType(LocationType locationType) {
        Location[] result;
        foreach (ref l; store)
            if (l.locationType == locationType) result ~= l;
        return result;
    }

    Location[] findByParent(LocationId parentId) {
        Location[] result;
        foreach (ref l; store)
            if (l.parentLocationId == parentId) result ~= l;
        return result;
    }

    void save(Location location) { store ~= location; }

    void update(Location location) {
        foreach (ref l; store)
            if (l.id == location.id) { l = location; return; }
    }

    void remove(LocationId id) {
        import std.algorithm : remove;
        store = store.remove!(l => l.id == id);
    }
}
