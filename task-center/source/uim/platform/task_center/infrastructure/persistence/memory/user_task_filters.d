/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.user_task_filters;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryUserTaskFilterRepository : TenantRepository!(UserTaskFilter, UserTaskFilterId), UserTaskFilterRepository {


    size_t countByUser(TenantId tenantId, string userId) {
        return findByUser(tenantId, userId).length;
    }
    UserTaskFilter[] findByUser(TenantId tenantId, string userId) {
        UserTaskFilter[] result;
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.userId == userId) result ~= f;
        return result;
    }
    void removeByUser(TenantId tenantId, string userId) {
        if (auto arr = tenantId in store) {
            UserTaskFilter[] filtered;
            foreach (f; *arr)
                if (f.userId != userId) filtered ~= f;
            store[tenantId] = filtered;
        }
    }

    UserTaskFilter findDefault(TenantId tenantId, string userId) {
        if (auto arr = tenantId in store)
            foreach (f; *arr)
                if (f.userId == userId && f.isDefault) return f;
        return UserTaskFilter.init;
    }

}
