/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.data_contexts;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryDataContextRepository : TenantRepository!(DataContext, DataContextId), DataContextRepository {

    size_t countByInstance(SituationInstanceId instanceId) {
        return findByInstance(instanceId).length;
    }
    DataContext[] findByInstance(SituationInstanceId instanceId) {
        return findAll().filter!(d => d.instanceId == instanceId).array;
    }
    void removeByInstance(SituationInstanceId instanceId) {
        store = findAll().filter!(d => d.instanceId != instanceId).array;
    }

    size_t countPersonalData(TenantId tenantId) {
        return findPersonalData(tenantId).length;
    }
    DataContext[] findPersonalData(TenantId tenantId) {
        return findAll().filter!(d => d.tenantId == tenantId && d.containsPersonalData).array;
    }
    void removePersonalData(TenantId tenantId) {
        store = findAll().filter!(d => !(d.tenantId == tenantId && d.containsPersonalData)).array;
    }

}
