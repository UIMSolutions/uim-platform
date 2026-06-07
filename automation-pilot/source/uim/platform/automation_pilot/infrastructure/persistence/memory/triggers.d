/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.triggers;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class MemoryTriggerRepository : TenantRepository!(Trigger, TriggerId), TriggerRepository {

    size_t countByCommand(TenantId tenantId, CommandId commandId) {
        return findByCommand(tenantId, commandId).length;
    }

    Trigger[] filterByCommand(Trigger[] triggers, CommandId commandId) {
        return triggers.filter!(e => e.commandId == commandId).array;
    }

    Trigger[] findByCommand(TenantId tenantId, CommandId commandId) {
        return filterByCommand(findByTenant(tenantId), commandId);
    }

    void removeByCommand(TenantId tenantId, CommandId commandId) {
        findByCommand(tenantId, commandId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, TriggerStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Trigger[] filterByStatus(Trigger[] triggers, TriggerStatus status) {
        return triggers.filter!(e => e.status == status).array;
    }

    Trigger[] findByStatus(TenantId tenantId, TriggerStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, TriggerStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
}
