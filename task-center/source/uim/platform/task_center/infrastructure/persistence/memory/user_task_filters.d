/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.user_task_filters;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryUserTaskFilterRepository : UserTaskFilterRepository {
    private UserTaskFilter[][string] store;

    UserTaskFilter findById(string tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.id == id) return f;
        return UserTaskFilter.init;
    }

    UserTaskFilter[] findByTenant(string tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return [];
    }

    UserTaskFilter[] findByUser(string tenantId, string userId) {
        UserTaskFilter[] result;
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.userId == userId) result ~= f;
        return result;
    }

    UserTaskFilter findDefault(string tenantId, string userId) {
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.userId == userId && f.isDefault) return f;
        return UserTaskFilter.init;
    }

    void save(string tenantId, UserTaskFilter entity) {
        store[tenantId] ~= entity;
    }

    void update(string tenantId, UserTaskFilter entity) {
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.id == entity.id) { f = entity; return; }
    }

    void remove(string tenantId, string id) {
        if (auto arr = tenantId in store) {
            UserTaskFilter[] filtered;
            foreach (f; *arr)
                if (f.id != id) filtered ~= f;
            store[tenantId] = filtered;
        }
    }
}
