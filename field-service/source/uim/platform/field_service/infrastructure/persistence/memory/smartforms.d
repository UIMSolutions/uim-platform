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

    bool existsById(SmartformId id) {
        return store.any!(e => e.id == id);
    }

    Smartform findById(SmartformId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Smartform.init;
    }

    Smartform[] findAll() { return store; }

    Smartform[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Smartform[] findByServiceCall(ServiceCallId serviceCallId) {
        return store.filter!(e => e.serviceCallId == serviceCallId).array;
    }

    Smartform[] findByActivity(ActivityId activityId) {
        return store.filter!(e => e.activityId == activityId).array;
    }

    Smartform[] findByStatus(SmartformStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Smartform smartform) { store ~= smartform; }

    void update(Smartform smartform) {
        foreach (e; store)
            if (e.id == smartform.id) { e = smartform; return; }
    }

    void remove(SmartformId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
