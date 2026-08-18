/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.ports.usecases.actions;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

interface IManageActionsUseCase {

    UsecaseResult createAction(TenantId tenantId, CreateActionRequest req);

    QueryResult getAction(TenantId tenantId, ActionId id);

    QueryResult listActions(TenantId tenantId);

    UsecaseResult updateAction(TenantId tenantId, ActionId id, UpdateActionRequest req);

    UsecaseResult deleteAction(TenantId tenantId, ActionId id);

}
