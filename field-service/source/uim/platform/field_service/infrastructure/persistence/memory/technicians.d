/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryTechnicianRepository : TechnicianRepository {
    private Technician[] store;

    bool existsById(TechnicianId id) {
        return store.any!(e => e.id == id);
    }

    Technician findById(TechnicianId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Technician.init;
    }

    Technician[] findAll() { return store; }

    Technician[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Technician[] findByStatus(TechnicianStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    Technician[] findByRegion(string region) {
        return store.filter!(e => e.region == region).array;
    }

    void save(Technician technician) { store ~= technician; }

    void update(Technician technician) {
        foreach (e; store)
            if (e.id == technician.id) { e = technician; return; }
    }

    void remove(TechnicianId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
