/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.triggers;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageTriggersUseCase { 

    UsecaseResult createTrigger(CreateTriggerRequest r);
    Trigger getTrigger(TenantId tenantId, TriggerId triggerId);
    Trigger[] listTriggers(TenantId tenantId);
    Trigger[] listTriggers(TenantId tenantId, ProcessId processId);
    UsecaseResult updateTrigger(UpdateTriggerRequest r);
    UsecaseResult deleteTrigger(TenantId tenantId, TriggerId triggerId);

}
