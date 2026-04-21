/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface TriggerRepository : ITenantRepository!(Trigger, TriggerId) {
    
    size_t countByStatus(TriggerStatus status);
    Trigger[] findByStatus(TriggerStatus status);
    void removeByStatus(TriggerStatus status);

    size_t countByCommand(CommandId commandId);
    Trigger[] findByCommand(CommandId commandId);
    void removeByCommand(CommandId commandId);

}
