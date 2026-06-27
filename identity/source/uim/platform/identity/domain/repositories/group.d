/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.domain.repositories.group;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

interface GroupRepository : ITentRepository!(IDMGroup, IDMGroupId) {

    IDMGroup findByName(TenantId tenantId, string name);
    IDMGroup[] findByType(TenantId tenantId, GroupType type_);
    IDMGroup[] findByMember(TenantId tenantId, UserId userId);

}
