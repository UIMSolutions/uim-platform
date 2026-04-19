/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.ui_components;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryUIComponentRepository : UIComponentRepository {
    private UIComponent[] store;

    bool existsById(UIComponentId id) {
        return store.any!(e => e.id == id);
    }

    UIComponent findById(UIComponentId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return UIComponent.init;
    }

    UIComponent[] findAll() { return store; }

    UIComponent[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    UIComponent[] findByCategory(ComponentCategory category) {
        return store.filter!(e => e.category == category).array;
    }

    void save(UIComponent entity) { store ~= entity; }

    void update(UIComponent entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(UIComponentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
