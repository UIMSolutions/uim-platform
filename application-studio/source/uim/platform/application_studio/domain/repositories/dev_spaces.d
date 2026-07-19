/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.dev_spaces;

import uim.platform.application_studio;
mixin(ShowModule!());

@safe:

interface DevSpaceRepository : ITenantRepository!(DevSpace, DevSpaceId) {

    size_t countByOwner(TenantId tenantId, string owner);
    DevSpace[] findByOwner(TenantId tenantId, string owner);
    void removeByOwner(TenantId tenantId, string owner);

    size_t countByStatus(TenantId tenantId, DevSpaceStatus status);
    DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status);
    void removeByStatus(TenantId tenantId, DevSpaceStatus status);

}
