/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.repositories.dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceTypeRepository : TenantRepository!(DevSpaceType, DevSpaceTypeId), DevSpaceTypeRepository {

    size_t countByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        return findByCategory(tenantId, category).length;
    }

    DevSpaceType[] findByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        return findByTenant(tenantId).filter!(e => e.category == category).array;
    }

    void removeByCategory(TenantId tenantId, DevSpaceTypeCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }

}
