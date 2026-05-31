/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.persistence.memory.action_repo;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class MemoryActionRepository
    : TenantRepository!(Action, ActionId),
      ActionRepository
{
    Action findByName(TenantId tenantId, string name) {
        foreach (a; findByTenant(tenantId))
            if (a.name == name) return a;
        return null;
    }
}
