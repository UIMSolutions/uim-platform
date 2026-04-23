/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

    size_t countByDevSpace(DevSpaceId devSpaceId) {
        return findByDevSpace(devSpaceId).length;
    }

    ServiceBinding[] findByDevSpace(DevSpaceId devSpaceId) {
        return findAll().filter!(e => e.devSpaceId == devSpaceId).array;
    }
    
    void removeByDevSpace(DevSpaceId devSpaceId) {
        findByDevSpace(devSpaceId).each!(e => remove(e));
    }

    size_t countByStatus(BindingStatus status) {
        return findByStatus(status).length;
    }

    ServiceBinding[] findByStatus(BindingStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(BindingStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
