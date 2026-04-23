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

    bool existsById(EquipmentId id) {
        return store.any!(e => e.id == id);
    }

    Equipment findById(EquipmentId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return null;
    }

    Equipment[] findAll() { return store; }

    Equipment[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Equipment[] findByCustomer(CustomerId customerId) {
        return findAll().filter!(e => e.customerId == customerId).array;
    }

    Equipment[] findByType(EquipmentType equipmentType) {
        return findAll().filter!(e => e.equipmentType == equipmentType).array;
    }

    Equipment[] findByStatus(EquipmentStatus status) {
        return findAll().filter!(e => e.status == status).array;
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
