/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryExtensionRepository : ExtensionRepository {
    private Extension[] store;

    bool existsById(ExtensionId id) {
        return store.any!(e => e.id == id);
    }

    Extension findById(ExtensionId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Extension.init;
    }

    Extension[] findAll() { return store; }

    Extension[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Extension[] findByScope(ExtensionScope scope_) {
        return findAll().filter!(e => e.scope_ == scope_).array;
    }

    Extension[] findByStatus(ExtensionStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(Extension entity) { store ~= entity; }

    void update(Extension entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ExtensionId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
