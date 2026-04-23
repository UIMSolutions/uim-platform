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

    bool existsByName(string name, TenantId tenantId);
    TaskProvider findByName(string name, TenantId tenantId);
    void removeByName(string name, TenantId tenantId);

    size_t countByStatus(ProviderStatus status, TenantId tenantId);
    TaskProvider[] findByStatus(ProviderStatus status, TenantId tenantId);
    void removeByStatus(ProviderStatus status, TenantId tenantId);

    size_t countByType(ProviderType providerType, TenantId tenantId);
    TaskProvider[] findByType(ProviderType providerType, TenantId tenantId);
    void removeByType(ProviderType providerType, TenantId tenantId);

}
