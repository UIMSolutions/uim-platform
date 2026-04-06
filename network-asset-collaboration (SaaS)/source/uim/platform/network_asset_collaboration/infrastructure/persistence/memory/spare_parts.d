/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.spare_parts;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemorySparePartRepository : SparePartRepository {
    private SparePart[] store;

    SparePart[] findAll() { return store; }

    SparePart* findById(SparePartId id) {
        foreach (ref sp; store)
            if (sp.id == id) return &sp;
        return null;
    }

    SparePart[] findByTenant(TenantId tenantId) {
        SparePart[] result;
        foreach (ref sp; store)
            if (sp.tenantId == tenantId) result ~= sp;
        return result;
    }

    SparePart[] findByModel(string modelId) {
        SparePart[] result;
        foreach (ref sp; store)
            if (sp.modelId == modelId) result ~= sp;
        return result;
    }

    SparePart[] findByPartNumber(string partNumber) {
        SparePart[] result;
        foreach (ref sp; store)
            if (sp.partNumber == partNumber) result ~= sp;
        return result;
    }

    SparePart[] findByManufacturer(string manufacturer) {
        SparePart[] result;
        foreach (ref sp; store)
            if (sp.manufacturer == manufacturer) result ~= sp;
        return result;
    }

    void save(SparePart sparePart) { store ~= sparePart; }

    void update(SparePart sparePart) {
        foreach (ref sp; store)
            if (sp.id == sparePart.id) { sp = sparePart; return; }
    }

    void remove(SparePartId id) {
        import std.algorithm : remove;
        store = store.remove!(sp => sp.id == id);
    }
}
