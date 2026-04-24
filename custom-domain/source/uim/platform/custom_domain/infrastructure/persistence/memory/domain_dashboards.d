/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.domain_dashboards;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDomainDashboardRepository : DomainDashboardRepository {
    private DomainDashboard[] store;

    DomainDashboard findById(DomainDashboardId id) {
        foreach (d; findAll) {
            if (d.id == id)
                return d;
        }
        return DomainDashboard.init;
    }

    DomainDashboard findByTenant(TenantId tenantId) {
        foreach (d; findAll) {
            if (d.tenantId == tenantId)
                return d;
        }
        return DomainDashboard.init;
    }

    void save(DomainDashboard d) {
        store ~= d;
    }

    void update(DomainDashboard d) {
        foreach (existing; findAll) {
            if (existing.id == d.id) {
                existing = d;
                return;
            }
        }
    }

    void remove(DomainDashboardId id) {
        store = findAll().filter!(d => d.id != id).array;
    }
}
