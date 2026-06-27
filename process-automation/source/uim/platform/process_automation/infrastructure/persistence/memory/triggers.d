/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.triggers;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class MemoryTriggerRepository : TentRepository!(Trigger, TriggerId), TriggerRepository {

    size_t countByProcess(TenantId tenantId, ProcessId processId) {
        return findByProcess(tenantId, processId).length;
    }
    Trigger[] filterByProcess(Trigger[] triggers, ProcessId processId) {
        return triggers.filter!(t => t.processId == processId).array;
    }
    Trigger[] findByProcess(TenantId tenantId, ProcessId processId) {
        return filterByProcess(findByTenant(tenantId), processId);
    }
    void removeByProcess(TenantId tenantId, ProcessId processId) {
        findByProcess(tenantId, processId).each!(t => remove(t));
    }

}
