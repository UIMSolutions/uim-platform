/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ProjectRepository : ITenantRepository!(Project, ProjectId) {

    size_t countByDevSpace(TenantId tenantId, DevSpaceId devSpaceId);
    Project[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId);
    void removeByDevSpace(TenantId tenantId, DevSpaceId devSpaceId);

    size_t countByType(TenantId tenantId, ProjectType projectType);
    Project[] findByType(TenantId tenantId, ProjectType projectType);
    void removeByType(TenantId tenantId, ProjectType projectType);

}
