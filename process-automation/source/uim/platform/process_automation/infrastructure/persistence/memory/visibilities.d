/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.visibilities;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryVisibilityRepository : TenantRepository!(Visibility, VisibilityId), VisibilityRepository {

    size_t countByProcess(TenantId tenantId, ProcessId processId) {
        return findByProcess(tenantId, processId).length;
    }

    Visibility[] filterByProcess(Visibility[] items, ProcessId processId) {
        return items.filter!(v => v.processId == processId).array;
    }

    Visibility[] findByProcess(TenantId tenantId, ProcessId processId) {
        return filterByProcess(findByTenant(tenantId), processId);
    }

    void removeByProcess(TenantId tenantId, ProcessId processId) {
        findByProcess(tenantId, processId).each!(entity => remove(entity));
    }
}
