/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.data_contexts;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryDataContextRepository : DataContextRepository {
    private DataContext[] store;

    DataContext findById(DataContextId id) {
        foreach (d; findAll) {
            if (d.id == id)
                return d;
        }
        return DataContext.init;
    }

    DataContext[] findByTenant(TenantId tenantId) {
        return findAll().filter!(d => d.tenantId == tenantId).array;
    }

    DataContext[] findByInstance(SituationInstanceId instanceId) {
        return findAll().filter!(d => d.instanceId == instanceId).array;
    }

    DataContext[] findPersonalData(TenantId tenantId) {
        return findAll().filter!(d => d.tenantId == tenantId && d.containsPersonalData).array;
    }

    void save(DataContext d) {
        store ~= d;
    }

    void update(DataContext d) {
        foreach (existing; findAll) {
            if (existing.id == d.id) {
                existing = d;
                return;
            }
        }
    }

    void remove(DataContextId id) {
        store = findAll().filter!(d => d.id != id).array;
    }

    void removeByInstance(SituationInstanceId instanceId) {
        store = findAll().filter!(d => d.instanceId != instanceId).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return findAll().filter!(d => d.tenantId == tenantId).array.length;
    }
}
