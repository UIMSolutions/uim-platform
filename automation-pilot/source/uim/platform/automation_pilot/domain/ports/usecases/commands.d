/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ManageCommandsUseCase { 
    
    Command getCommand(TenantId tenantId, CommandId id);
    Command[] listCommands(TenantId tenantId);
    Command[] listCommands(TenantId tenantId, CatalogId catalogId);
    UsecaseResult createCommand(CommandDTO dto);
    UsecaseResult updateCommand(CommandDTO dto);
    UsecaseResult deleteCommand(TenantId tenantId, CommandId id);

}
