/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.memory.team_types;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemoryTeamTypeRepository
    : TenantRepository!(TeamType, TeamTypeId),
      TeamTypeRepository {

    TeamType[] findByCategory(TenantId tenantId, string categoryId) {
        return findByTenant(tenantId).filter!(t => t.categoryId == categoryId).array;
    }

    TeamType findByCode(TenantId tenantId, string code) {
        auto items = findByTenant(tenantId).filter!(t => t.code == code).array;
        return items.length > 0 ? items[0] : TeamType.init;
    }
}
