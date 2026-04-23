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

    ServiceAccount[] findByStatus(TenantId tenantId, ServiceAccountStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ServiceAccountStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
