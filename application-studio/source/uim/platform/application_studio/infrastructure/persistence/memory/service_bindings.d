/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : ServiceBindingRepository {
    private ServiceBinding[] store;

    bool existsById(ServiceBindingId id) {
        return store.any!(e => e.id == id);
    }

    ServiceBinding findById(ServiceBindingId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ServiceBinding.init;
    }

    ServiceBinding[] findAll() { return store; }

    ServiceBinding[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ServiceBinding[] findByDevSpace(DevSpaceId devSpaceId) {
        return store.filter!(e => e.devSpaceId == devSpaceId).array;
    }

    ServiceBinding[] findByStatus(BindingStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(ServiceBinding entity) { store ~= entity; }

    void update(ServiceBinding entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ServiceBindingId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
