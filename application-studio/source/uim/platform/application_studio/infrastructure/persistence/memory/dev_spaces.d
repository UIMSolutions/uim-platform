/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceRepository : TenantRepository!(DevSpace, DevSpaceId), DevSpaceRepository {

    size_t countByOwner(string owner) {
        return findByOwner(owner).length;
    }

    DevSpace[] findByOwner(string owner) {
        return findAll().filter!(e => e.owner == owner).array;
    }

    void removeByOwner(string owner) {
        findByOwner(owner).each!(e => remove(e));
    }

    size_t countByStatus(DevSpaceStatus status) {
        return findByStatus(status).length;
    }

    DevSpace[] findByStatus(DevSpaceStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(DevSpaceStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
