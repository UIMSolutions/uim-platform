/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskProviderRepository : TenantRepository!(TaskProvider, TaskProviderId), TaskProviderRepository {
    private TaskProvider[][string] store;

    TaskProvider findById(string tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (p; *arr)
                if (p.id == id) return p;
        return TaskProvider.init;
    }

    TaskProvider[] findByTenant(string tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return [];
    }

    TaskProvider[] findByName(string tenantId, string name) {
        TaskProvider[] result;
        if (auto arr = tenantId in store)
            foreach (p; *arr)
                if (p.name == name) result ~= p;
        return result;
    }

    TaskProvider[] findByStatus(string tenantId, ProviderStatus status) {
        TaskProvider[] result;
        if (auto arr = tenantId in store)
            foreach (p; *arr)
                if (p.status == status) result ~= p;
        return result;
    }

    TaskProvider[] findByType(string tenantId, ProviderType ptype) {
        TaskProvider[] result;
        if (auto arr = tenantId in store)
            foreach (p; *arr)
                if (p.providerType == ptype) result ~= p;
        return result;
    }

    void save(string tenantId, TaskProvider entity) {
        store[tenantId] ~= entity;
    }

    void update(string tenantId, TaskProvider entity) {
        if (auto arr = tenantId in store)
            foreach (p; *arr)
                if (p.id == entity.id) { p = entity; return; }
    }

    void remove(string tenantId, string id) {
        if (auto arr = tenantId in store) {
            TaskProvider[] filtered;
            foreach (p; *arr)
                if (p.id != id) filtered ~= p;
            store[tenantId] = filtered;
        }
    }
}
