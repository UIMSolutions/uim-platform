/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface ProjectRepository {
    bool existsById(ProjectId id);
    Project findById(ProjectId id);

    Project[] findAll();
    Project[] findByTenant(TenantId tenantId);
    Project[] findByDevSpace(DevSpaceId devSpaceId);
    Project[] findByType(ProjectType projectType);

    void save(Project entity);
    void update(Project entity);
    void remove(ProjectId id);
}
