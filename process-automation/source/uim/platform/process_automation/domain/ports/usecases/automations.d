/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.automations;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageAutomationsUseCase { 

    CommandResult createAutomation(CreateAutomationRequest r);
    Automation getAutomation(TenantId tenantId, AutomationId id);
    Automation[] listAutomations(TenantId tenantId);
    CommandResult updateAutomation(UpdateAutomationRequest r);
    CommandResult deleteAutomation(TenantId tenantId, AutomationId id);

}
