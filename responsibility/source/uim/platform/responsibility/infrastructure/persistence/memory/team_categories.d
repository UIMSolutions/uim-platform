/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.memory.team_categories;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class MemoryTeamCategoryRepository
    : TentRepository!(TeamCategory, TeamCategoryId),
      TeamCategoryRepository {

    TeamCategory findByCode(TenantId tenantId, string code) {
        auto items = findByTenant(tenantId).filter!(c => c.code == code).array;
        return items.length > 0 ? items[0] : TeamCategory.init;
    }
}
