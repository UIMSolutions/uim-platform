/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskProviderRepository {
    TaskProvider findById(TaskProviderId id);
    TaskProvider[] findByTenant(TenantId tenantId);
    TaskProvider findByName(string name);
    TaskProvider[] findByStatus(ProviderStatus status);
    TaskProvider[] findByType(ProviderType providerType);
    void save(TaskProvider entity);
    void update(TaskProvider entity);
    void remove(TaskProviderId id);
}
