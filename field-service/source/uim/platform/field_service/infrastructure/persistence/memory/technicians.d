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

    Technician[] findAll() { return store; }

    Technician* findById(TechnicianId id) {
        foreach (e; store)
            if (e.id == id) return &e;
        return null;
    }

    Technician[] findByTenant(TenantId tenantId) {
        Technician[] result;
        foreach (e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Technician[] findByStatus(TechnicianStatus status) {
        Technician[] result;
        foreach (e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    Technician[] findByRegion(string region) {
        Technician[] result;
        foreach (e; store)
            if (e.region == region) result ~= e;
        return result;
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
