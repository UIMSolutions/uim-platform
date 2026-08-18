/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.ports.usecases.conditions;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

interface IManageConditionsUseCase {
    
    UsecaseResult createCondition(TenantId tenantId, CreateConditionRequest req);

    QueryResult getCondition(TenantId tenantId, string id);

    QueryResult listConditions(TenantId tenantId);

    UsecaseResult updateCondition(TenantId tenantId, string id, UpdateConditionRequest req);

    UsecaseResult deleteCondition(TenantId tenantId, string id);

}
