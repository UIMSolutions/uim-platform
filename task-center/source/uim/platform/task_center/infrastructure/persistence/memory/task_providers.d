/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_providers;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class MemoryTaskProviderRepository : TenantRepository!(TaskProvider, TaskProviderId), TaskProviderRepository {

    bool existsByName(TenantId tenantId, string name) {
        return findByName(tenantId, name).id != TaskProviderId.init;
    }
    TaskProvider findByName(TenantId tenantId, string name) {
        foreach (p; findByTenant(tenantId))
            if (p.name == name) return p;
        return TaskProvider.init;
    }
    void removeByName(TenantId tenantId, string name) {
        auto provider = findByName(tenantId, name);
        if (provider.id != TaskProviderId.init) remove(provider);
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

    size_t countByType(TenantId tenantId, ProviderType ptype) {
        return findByType(tenantId, ptype).length;
    }
    TaskProvider[] findByType(TenantId tenantId, ProviderType ptype) {
        return findByTenant(tenantId).filter!(p => p.providerType == ptype).array;
    }

    void removeByType(TenantId tenantId, ProviderType ptype) {
        findByType(tenantId, ptype).each!(p => remove(p));
    }

}
