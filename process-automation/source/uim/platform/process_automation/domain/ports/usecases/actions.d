/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.actions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageActionsUseCase { 

    UsecaseResult createAction(CreateActionRequest r);
    Action getAction(TenantId tenantId, ActionId id);
    Action[] listActions(TenantId tenantId);
    UsecaseResult updateAction(UpdateActionRequest r);
    UsecaseResult deleteAction(TenantId tenantId, ActionId actionId);

}
