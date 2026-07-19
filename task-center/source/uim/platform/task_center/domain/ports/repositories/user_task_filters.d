/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.user_task_filters;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

interface UserTaskFilterRepository : ITenantRepository!(UserTaskFilter, UserTaskFilterId) {

    // bool existsDefault(TenantId tenantId, UserId userId);
    // UserTaskFilter findDefault(TenantId tenantId, UserId userId);
    // void removeDefault(TenantId tenantId, UserId userId);

    size_t countByUser(TenantId tenantId, UserId userId);
    UserTaskFilter[] findByUser(TenantId tenantId, UserId userId);
    void removeByUser(TenantId tenantId, UserId userId);

}
