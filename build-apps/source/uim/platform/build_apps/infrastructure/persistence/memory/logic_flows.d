/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryLogicFlowRepository : LogicFlowRepository {
    private LogicFlow[] store;

    bool existsById(LogicFlowId id) {
        return store.any!(e => e.id == id);
    }

    LogicFlow findById(LogicFlowId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return LogicFlow.init;
    }

    LogicFlow[] findAll() { return store; }

    LogicFlow[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    LogicFlow[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    LogicFlow[] findByPage(PageId pageId) {
        return store.filter!(e => e.pageId == pageId).array;
    }

    void save(LogicFlow entity) { store ~= entity; }

    void update(LogicFlow entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(LogicFlowId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
