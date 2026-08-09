/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:
interface IManageCommandInputsUseCase { 
    
    CommandInput getCommandInput(TenantId tenantId, CommandInputId id);
    CommandInput[] listCommandInputs(TenantId tenantId);
    CommandResult createCommandInput(CommandInputDTO dto);
    CommandResult updateCommandInput(CommandInputDTO dto);
    CommandResult deleteCommandInput(TenantId tenantId, CommandInputId id);
    
}
