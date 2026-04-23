/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.branding_configs;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryBrandingConfigRepository : BrandingConfigRepository {
    private BrandingConfig[] store;

    bool existsById(BrandingConfigId id) {
        return store.any!(e => e.id == id);
    }

    BrandingConfig findById(BrandingConfigId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return BrandingConfig.init;
    }

    BrandingConfig[] findAll() { return store; }

    BrandingConfig[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    void save(BrandingConfig entity) { store ~= entity; }

    void update(BrandingConfig entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(BrandingConfigId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
