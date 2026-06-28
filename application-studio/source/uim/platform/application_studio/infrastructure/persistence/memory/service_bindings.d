/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.service_bindings;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

    size_t countByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return findByDevSpace(tenantId, devSpaceId).length;
    }

    ServiceBinding[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return find(tenantId).filter!(e => e.devSpaceId == devSpaceId).array;
    }
    
    void removeByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        findByDevSpace(tenantId, devSpaceId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, BindingStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, BindingStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
