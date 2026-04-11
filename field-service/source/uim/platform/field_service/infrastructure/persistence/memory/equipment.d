/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryEquipmentRepository : EquipmentRepository {
    private Equipment[] store;

    Equipment[] findAll() { return store; }

    Equipment* findById(EquipmentId id) {
        foreach (e; store)
            if (e.id == id) return &e;
        return null;
    }

    Equipment[] findByTenant(TenantId tenantId) {
        Equipment[] result;
        foreach (e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Equipment[] findByCustomer(CustomerId customerId) {
        Equipment[] result;
        foreach (e; store)
            if (e.customerId == customerId) result ~= e;
        return result;
    }

    Equipment[] findByType(EquipmentType equipmentType) {
        Equipment[] result;
        foreach (e; store)
            if (e.equipmentType == equipmentType) result ~= e;
        return result;
    }

    Equipment[] findByStatus(EquipmentStatus status) {
        Equipment[] result;
        foreach (e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Equipment equipment) { store ~= equipment; }

    void update(Equipment equipment) {
        foreach (e; store)
            if (e.id == equipment.id) { e = equipment; return; }
    }

    void remove(EquipmentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
