/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.domain_dashboards;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface DomainDashboardRepository {
    DomainDashboard findById(DomainDashboardId id);
    DomainDashboard findByTenant(TenantId tenantId);
    void save(DomainDashboard d);
    void update(DomainDashboard d);
    void remove(DomainDashboardId id);
}
