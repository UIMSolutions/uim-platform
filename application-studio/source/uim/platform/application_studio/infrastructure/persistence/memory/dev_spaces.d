/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.dev_spaces;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class MemoryDevSpaceRepository : TentRepository!(DevSpace, DevSpaceId), DevSpaceRepository {

    size_t countByOwner(TenantId tenantId, string owner) {
        return findByOwner(tenantId, owner).length;
    }

    DevSpace[] findByOwner(TenantId tenantId, string owner) {
        return findByTenant(tenantId).filter!(e => e.owner == owner).array;
    }

    void removeByOwner(TenantId tenantId, string owner) {
        findByOwner(tenantId, owner).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, DevSpaceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, DevSpaceStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
