/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.service_accounts;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryServiceAccountRepository : TenantRepository!(ServiceAccount, ServiceAccountId), ServiceAccountRepository {

    size_t countByStatus(TenantId tenantId, ServiceAccountStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceAccount[] filterByStatus(ServiceAccount[] accounts, ServiceAccountStatus status) {
        return accounts.filter!(a => a.status == status).array;
    }

    ServiceAccount[] findByStatus(TenantId tenantId, ServiceAccountStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ServiceAccountStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
