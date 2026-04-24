/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceTypeRepository : TenantRepository!(DevSpaceType, DevSpaceTypeId), DevSpaceTypeRepository {

    size_t countByCategory(DevSpaceTypeCategory category) {
        return findByCategory(category).length;
    }

    DevSpaceType[] findByCategory(DevSpaceTypeCategory category) {
        return findAll().filter!(e => e.category == category).array;
    }

    void removeByCategory(DevSpaceTypeCategory category) {
        findByCategory(category).each!(e => remove(e));
    }

}
