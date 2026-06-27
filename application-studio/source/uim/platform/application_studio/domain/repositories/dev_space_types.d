/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.dev_space_types;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

interface DevSpaceTypeRepository : ITenantRepository!(DevSpaceType, DevSpaceTypeId) {

    size_t countByCategory(TenantId tenantId, DevSpaceTypeCategory category);
    DevSpaceType[] findByCategory(TenantId tenantId, DevSpaceTypeCategory category);
    void removeByCategory(TenantId tenantId, DevSpaceTypeCategory category);

}
