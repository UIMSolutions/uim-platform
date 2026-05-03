/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskActionRepository : TenantRepository!(TaskAction, TaskActionId), TaskActionRepository {

    size_t countByTask(TenantId tenantId, string taskId) {
        return findByTask(tenantId, taskId).length;
    }
    TaskAction[] findByTask(TenantId tenantId, string taskId) {
        return findByTenant(tenantId).filter!(a => a.taskId == taskId).array;
    }
    void removeByTask(TenantId tenantId, string taskId) {
        findByTask(tenantId, taskId).each!(a => remove(a));
    }

    size_t countByPerformer(TenantId tenantId, string performerId) {
        return findByPerformer(tenantId, performerId).length;
    }
    TaskAction[] findByPerformer(TenantId tenantId, string performerId) {
        return findByTenant(tenantId).filter!(a => a.performedBy == performerId).array;
    }
    void removeByPerformer(TenantId tenantId, string performerId) {
        findByPerformer(tenantId, performerId).each!(a => remove(a));
    }
}
