/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.equipment;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryEquipmentRepository : EquipmentRepository {
    private Equipment[] store;

    Equipment[] findAll() { return store; }

    Equipment* findById(EquipmentId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Equipment[] findByTenant(TenantId tenantId) {
        Equipment[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Equipment[] findByModel(ModelId modelId) {
        Equipment[] result;
        foreach (ref e; store)
            if (e.modelId == modelId) result ~= e;
        return result;
    }

    Equipment[] findByStatus(EquipmentStatus status) {
        Equipment[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    Equipment[] findByManufacturer(string manufacturer) {
        Equipment[] result;
        foreach (ref e; store)
            if (e.manufacturer == manufacturer) result ~= e;
        return result;
    }

    void save(Equipment equipment) { store ~= equipment; }

    void update(Equipment equipment) {
        foreach (ref e; store)
            if (e.id == equipment.id) { e = equipment; return; }
    }

    void remove(EquipmentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
