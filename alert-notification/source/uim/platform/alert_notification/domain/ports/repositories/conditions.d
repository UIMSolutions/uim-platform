/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.ports.repositories.conditions;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

interface ConditionRepository : ITenantRepository!(Condition, ConditionId) {
    Condition findByName(TenantId tenantId, string name);
}
