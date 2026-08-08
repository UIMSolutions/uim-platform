/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.ports.repositories.team_categories;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

interface ITeamCategoryRepository : ITenantRepository!(TeamCategory, TeamCategoryId) {
    TeamCategory findByCode(TenantId tenantId, string code);
}
