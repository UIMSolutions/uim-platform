/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.service_accounts;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ServiceAccountRepository {
    bool existsById(ServiceAccountId id);
    ServiceAccount findById(ServiceAccountId id);

    ServiceAccount[] findAll();
    ServiceAccount[] findByTenant(TenantId tenantId);
    ServiceAccount[] findByStatus(ServiceAccountStatus status);

    void save(ServiceAccount account);
    void update(ServiceAccount account);
    void remove(ServiceAccountId id);
}
