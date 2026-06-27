/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.triggers;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

interface TriggerRepository : ITentRepository!(Trigger, TriggerId) {
    
    size_t countByStatus(TenantId tenantId, TriggerStatus status);
    Trigger[] findByStatus(TenantId tenantId, TriggerStatus status);
    void removeByStatus(TenantId tenantId, TriggerStatus status);

    size_t countByCommand(TenantId tenantId, CommandId commandId);
    Trigger[] findByCommand(TenantId tenantId, CommandId commandId);
    void removeByCommand(TenantId tenantId, CommandId commandId);

}
