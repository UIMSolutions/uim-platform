/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.data_contexts;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class MemoryDataContextRepository : TentRepository!(DataContext, DataContextId), DataContextRepository {

    // #region ByInstance
    size_t countByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }
     DataContext[] filterByInstance(DataContext[] contexts, SituationInstanceId instanceId) {
        return contexts.filter!(d => d.instanceId == instanceId).array;
    }
    DataContext[] findByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId), instanceId);
    }
    void removeByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(d => remove(d));
    }
    // #endregion ByInstance

    // #region ByPersonalData
    size_t countByPersonalData(TenantId tenantId) {
        return findByPersonalData(tenantId).length;
    }
    DataContext[] filterByPersonalData(DataContext[] contexts) {
        return contexts.filter!(d => d.containsPersonalData).array;
    }
    DataContext[] findByPersonalData(TenantId tenantId) {
        return filterByPersonalData(findByTenant(tenantId));
    }
    void removeByPersonalData(TenantId tenantId) {
        findByPersonalData(tenantId).each!(d => remove(d));
    }
    // #endregion ByPersonalData

}
