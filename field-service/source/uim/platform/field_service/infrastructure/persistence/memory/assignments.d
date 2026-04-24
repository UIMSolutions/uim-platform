/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.assignments;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryAssignmentRepository : AssignmentRepository {
    private Assignment[] store;

    bool existsById(AssignmentId id) {
        return store.any!(e => e.id == id);
    }

    Assignment findById(AssignmentId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return Assignment.init; // or throw an exception
    }

    Assignment[] findAll() { return store; }

    Assignment[] findByTenant(TenantId tenantId) {
        return findAll.filter!(e => e.tenantId == tenantId).array;
    }

    Assignment[] findByActivity(ActivityId activityId) {
        return findAll.filter!(e => e.activityId == activityId).array;
    }

    Assignment[] findByTechnician(TechnicianId technicianId) {
        return findAll.filter!(e => e.technicianId == technicianId).array;
    }

    Assignment[] findByStatus(AssignmentStatus status) {
        return findAll.filter!(e => e.status == status).array;
    }

    void save(Assignment assignment) { store ~= assignment; }

    void update(Assignment assignment) {
        foreach (e; findAll)
            if (e.id == assignment.id) { e = assignment; return; }
    }

    void remove(AssignmentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
