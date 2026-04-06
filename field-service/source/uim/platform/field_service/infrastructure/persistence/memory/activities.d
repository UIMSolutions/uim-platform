/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryActivityRepository : ActivityRepository {
    private Activity[] store;

    Activity[] findAll() { return store; }

    Activity* findById(ActivityId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Activity[] findByTenant(TenantId tenantId) {
        Activity[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Activity[] findByServiceCall(ServiceCallId serviceCallId) {
        Activity[] result;
        foreach (ref e; store)
            if (e.serviceCallId == serviceCallId) result ~= e;
        return result;
    }

    Activity[] findByTechnician(TechnicianId technicianId) {
        Activity[] result;
        foreach (ref e; store)
            if (e.technicianId == technicianId) result ~= e;
        return result;
    }

    Activity[] findByStatus(ActivityStatus status) {
        Activity[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Activity activity) { store ~= activity; }

    void update(Activity activity) {
        foreach (ref e; store)
            if (e.id == activity.id) { e = activity; return; }
    }

    void remove(ActivityId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
