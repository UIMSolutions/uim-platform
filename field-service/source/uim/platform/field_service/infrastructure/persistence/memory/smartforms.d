/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.smartforms;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemorySmartformRepository : SmartformRepository {
    private Smartform[] store;

    Smartform[] findAll() { return store; }

    Smartform* findById(SmartformId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Smartform[] findByTenant(TenantId tenantId) {
        Smartform[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Smartform[] findByServiceCall(ServiceCallId serviceCallId) {
        Smartform[] result;
        foreach (ref e; store)
            if (e.serviceCallId == serviceCallId) result ~= e;
        return result;
    }

    Smartform[] findByActivity(ActivityId activityId) {
        Smartform[] result;
        foreach (ref e; store)
            if (e.activityId == activityId) result ~= e;
        return result;
    }

    Smartform[] findByStatus(SmartformStatus status) {
        Smartform[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Smartform smartform) { store ~= smartform; }

    void update(Smartform smartform) {
        foreach (ref e; store)
            if (e.id == smartform.id) { e = smartform; return; }
    }

    void remove(SmartformId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
