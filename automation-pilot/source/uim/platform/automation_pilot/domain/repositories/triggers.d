/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface TriggerRepository {
    bool existsById(TriggerId id);
    Trigger findById(TriggerId id);

    Trigger[] findAll();
    Trigger[] findByTenant(TenantId tenantId);
    Trigger[] findByCommand(CommandId commandId);
    Trigger[] findByStatus(TriggerStatus status);

    void save(Trigger trigger);
    void update(Trigger trigger);
    void remove(TriggerId id);
}
