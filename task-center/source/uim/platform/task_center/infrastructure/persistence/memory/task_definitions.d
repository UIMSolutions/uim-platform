/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_definitions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskDefinitionRepository : TaskDefinitionRepository {
    private TaskDefinition[][string] store;

    TaskDefinition findById(TenantId tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (d; *arr)
                if (d.id == id) return d;
        return TaskDefinition.init;
    }

    TaskDefinition[] findByTenant(TenantId tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return null;
    }

    TaskDefinition[] findByProvider(TenantId tenantId, string providerId) {
        TaskDefinition[] result;
        if (auto arr = tenantId in store)
            foreach (d; *arr)
                if (d.providerId == providerId) result ~= d;
        return result;
    }

    TaskDefinition[] findByCategory(TenantId tenantId, TaskCategory category) {
        TaskDefinition[] result;
        if (auto arr = tenantId in store)
            foreach (d; *arr)
                if (d.category == category) result ~= d;
        return result;
    }

    TaskDefinition[] findByName(TenantId tenantId, string name) {
        TaskDefinition[] result;
        if (auto arr = tenantId in store)
            foreach (d; *arr)
                if (d.name == name) result ~= d;
        return result;
    }

    void save(TenantId tenantId, TaskDefinition entity) {
        store[tenantId] ~= entity;
    }

    void update(TenantId tenantId, TaskDefinition entity) {
        if (auto arr = tenantId in store)
            foreach (d; *arr)
                if (d.id == entity.id) { d = entity; return; }
    }

    void remove(TenantId tenantId, string id) {
        if (auto arr = tenantId in store) {
            TaskDefinition[] filtered;
            foreach (d; *arr)
                if (d.id != id) filtered ~= d;
            store[tenantId] = filtered;
        }
    }
}
