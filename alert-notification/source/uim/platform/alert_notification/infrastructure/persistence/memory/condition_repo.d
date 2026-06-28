/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.persistence.memory.condition_repo;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

class MemoryConditionRepository
    : TenantRepository!(Condition, ConditionId),
      ConditionRepository
{
    Condition findByName(TenantId tenantId, string name) {
        foreach (c; find(tenantId))
            if (c.name == name) return c;
        return null;
    }
}
