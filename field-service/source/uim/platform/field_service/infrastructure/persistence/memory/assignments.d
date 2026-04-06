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

    Assignment[] findAll() { return store; }

    Assignment* findById(AssignmentId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Assignment[] findByTenant(TenantId tenantId) {
        Assignment[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Assignment[] findByActivity(ActivityId activityId) {
        Assignment[] result;
        foreach (ref e; store)
            if (e.activityId == activityId) result ~= e;
        return result;
    }

    Assignment[] findByTechnician(TechnicianId technicianId) {
        Assignment[] result;
        foreach (ref e; store)
            if (e.technicianId == technicianId) result ~= e;
        return result;
    }

    Assignment[] findByStatus(AssignmentStatus status) {
        Assignment[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Assignment assignment) { store ~= assignment; }

    void update(Assignment assignment) {
        foreach (ref e; store)
            if (e.id == assignment.id) { e = assignment; return; }
    }

    void remove(AssignmentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
