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

    UsecaseResult createAutomation(CreateAutomationRequest r);
    Automation getAutomation(TenantId tenantId, AutomationId id);
    Automation[] listAutomations(TenantId tenantId);
    UsecaseResult updateAutomation(UpdateAutomationRequest r);
    UsecaseResult deleteAutomation(TenantId tenantId, AutomationId id);

}
