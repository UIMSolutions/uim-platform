/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface IManageTriggersUseCase { 
    
    Trigger getTrigger(TenantId tenantId, TriggerId id);
    Trigger[] listTriggers(TenantId tenantId);
    Trigger[] listTriggers(TenantId tenantId, CommandId commandId);
    CommandResult createTrigger(TriggerDTO dto);
    CommandResult updateTrigger(TriggerDTO dto);
    CommandResult deleteTrigger(TenantId tenantId, TriggerId id);
     
}
