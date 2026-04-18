/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.service_accounts;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryServiceAccountRepository : ServiceAccountRepository {
    private ServiceAccount[] store;

    bool existsById(ServiceAccountId id) {
        return store.any!(e => e.id == id);
    }

    ServiceAccount findById(ServiceAccountId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ServiceAccount.init;
    }

    ServiceAccount[] findAll() { return store; }

    ServiceAccount[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ServiceAccount[] findByStatus(ServiceAccountStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(ServiceAccount account) { store ~= account; }

    void update(ServiceAccount account) {
        foreach (ref e; store)
            if (e.id == account.id) { e = account; return; }
    }

    void remove(ServiceAccountId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
