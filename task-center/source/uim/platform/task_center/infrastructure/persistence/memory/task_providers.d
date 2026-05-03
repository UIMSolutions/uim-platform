/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskProviderRepository : TenantRepository!(TaskProvider, TaskProviderId), TaskProviderRepository {

    size_t countByName(TenantId tenantId, string name) {
        return findByName(tenantId, name).length;
    }
    TaskProvider[] findByName(TenantId tenantId, string name) {
        return findByTenant(tenantId).filter!(p => p.name == name).array;
    }
    void removeByName(TenantId tenantId, string name) {
        findByName(tenantId, name).each!(p => remove(p));
    }

    size_t countByStatus(TenantId tenantId, ProviderStatus status) {
        return findByStatus(tenantId, status).length;
    }

    TaskProvider[] findByStatus(TenantId tenantId, ProviderStatus status) {
        return findByTenant(tenantId).filter!(p => p.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ProviderStatus status) {
        findByStatus(tenantId, status).each!(p => remove(p));
    }

    TaskProvider[] findByType(TenantId tenantId, ProviderType ptype) {
        return findByTenant(tenantId).filter!(p => p.providerType == ptype).array;
    }

    void removeByType(TenantId tenantId, ProviderType ptype) {
        findByType(tenantId, ptype).each!(p => remove(p));
    }

}
