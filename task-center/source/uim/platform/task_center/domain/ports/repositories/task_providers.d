/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskProviderRepository : ITenantRepository!(TaskProvider, TaskProviderId) {

    bool existsByName(TenantId tenantId, string name);
    TaskProvider findByName(TenantId tenantId, string name);
    void removeByName(TenantId tenantId, string name);

    size_t countByStatus(TenantId tenantId, ProviderStatus status);
    TaskProvider[] findByStatus(TenantId tenantId, ProviderStatus status);
    void removeByStatus(TenantId tenantId, ProviderStatus status);

    size_t countByType(TenantId tenantId, ProviderType providerType);
    TaskProvider[] findByType(TenantId tenantId, ProviderType providerType);
    void removeByType(TenantId tenantId, ProviderType providerType);

}
