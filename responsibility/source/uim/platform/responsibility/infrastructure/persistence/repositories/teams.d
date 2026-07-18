/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.repositories.teams;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemoryTeamRepository
    : TenantRepository!(Team, TeamId),
      TeamRepository {

    Team[] findByStatus(TenantId tenantId, TeamStatus status) {
        return findByTenant(tenantId).filter!(t => t.status == status).array;
    }

    Team[] findByType(TenantId tenantId, string teamTypeId) {
        return findByTenant(tenantId).filter!(t => t.teamTypeId == teamTypeId).array;
    }

    Team[] findByCategory(TenantId tenantId, string categoryId) {
        return findByTenant(tenantId).filter!(t => t.categoryId == categoryId).array;
    }
}
