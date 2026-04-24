/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryProjectRepository : TenantRepository!(Project, ProjectId), ProjectRepository {

    size_t countByDevSpace(DevSpaceId devSpaceId) {
        return findByDevSpace(devSpaceId).length;
    }

    Project[] findByDevSpace(DevSpaceId devSpaceId) {
        return findAll().filter!(e => e.devSpaceId == devSpaceId).array;
    }

    void removeByDevSpace(DevSpaceId devSpaceId) {
        findByDevSpace(devSpaceId).each!(e => remove(e));
    }

}
