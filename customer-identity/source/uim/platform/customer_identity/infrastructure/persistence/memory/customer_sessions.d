/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.repositories.customer_sessions;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class MemoryCustomerSessionRepository : TenantRepository!(CustomerSession, CustomerSessionId), CustomerSessionRepository {

    CustomerSession findByToken(TenantId tenantId, string token) {
        auto items = findByTenant(tenantId).filter!(s => s.token == token).array;
        return items.length > 0 ? items[0] : CustomerSession.init;
    }

    CustomerSession[] findByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByTenant(tenantId).filter!(s => s.customerId.value == customerId.value).array;
    }

    CustomerSession[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(s => s.status == SessionStatus.active).array;
    }

    void revokeByCustomer(TenantId tenantId, CustomerId customerId) {
        auto sessions = findByCustomer(tenantId, customerId);
        foreach (ref s; sessions) {
            s.status = SessionStatus.revoked;
            update(s);
        }
    }
}
