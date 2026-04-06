/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.data_contexts;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.data_context;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface DataContextRepository {
    DataContext findById(DataContextId id);
    DataContext[] findByTenant(TenantId tenantId);
    DataContext[] findByInstance(SituationInstanceId instanceId);
    DataContext[] findPersonalData(TenantId tenantId);
    void save(DataContext d);
    void update(DataContext d);
    void remove(DataContextId id);
    void removeByInstance(SituationInstanceId instanceId);
    long countByTenant(TenantId tenantId);
}
