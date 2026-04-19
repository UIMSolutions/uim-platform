/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryAppBuildRepository : AppBuildRepository {
    private AppBuild[] store;

    bool existsById(AppBuildId id) {
        return store.any!(e => e.id == id);
    }

    AppBuild findById(AppBuildId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return AppBuild.init;
    }

    AppBuild[] findAll() { return store; }

    AppBuild[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    AppBuild[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    void save(AppBuild entity) { store ~= entity; }

    void update(AppBuild entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(AppBuildId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
