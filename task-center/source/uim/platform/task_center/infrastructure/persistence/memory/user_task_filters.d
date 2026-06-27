/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.user_task_filters;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class MemoryUserTaskFilterRepository : TentRepository!(UserTaskFilter, UserTaskFilterId), UserTaskFilterRepository {

    // bool existsDefault(TenantId tenantId, UserId userId) {
    //     return findDefault(tenantId, userId).id != UserTaskFilterId.init;
    // }
    // UserTaskFilter findDefault(TenantId tenantId, UserId userId) {
    //     foreach (f; findByTenant(tenantId))
    //         if (f.isDefault) return f;
    //     return UserTaskFilter.init;
    // }
    // void removeDefault(TenantId tenantId, UserId userId) {
    //     auto filter = findDefault(tenantId, userId);
    //     if (filter.id != UserTaskFilterId.init) {
    //         remove(filter);
    //     }
    // }

    size_t countByUser(TenantId tenantId, UserId userId) {
        return findByUser(tenantId, userId).length;
    }

    UserTaskFilter[] findByUser(TenantId tenantId, UserId userId) {
        return findByTenant(tenantId).filter!(f => f.userId == userId).array;
    }
    
    void removeByUser(TenantId tenantId, UserId userId) {
        foreach (f; findByUser(tenantId, userId))
            remove(f);
    }
}
