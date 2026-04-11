/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.dashboards;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryDashboardRepository : DashboardRepository {
    private Dashboard[] store;

    Dashboard findById(DashboardId id) {
        foreach (d; store) {
            if (d.id == id)
                return d;
        }
        return Dashboard.init;
    }

    Dashboard[] findByTenant(TenantId tenantId) {
        return store.filter!(d => d.tenantId == tenantId).array;
    }

    Dashboard[] findByType(TenantId tenantId, DashboardType type) {
        return store.filter!(d => d.tenantId == tenantId && d.type == type).array;
    }

    void save(Dashboard d) {
        store ~= d;
    }

    void update(Dashboard d) {
        foreach (existing; store) {
            if (existing.id == d.id) {
                existing = d;
                return;
            }
        }
    }

    void remove(DashboardId id) {
        store = store.filter!(d => d.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(d => d.tenantId == tenantId).array.length;
    }
}
