/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.customer_sessions;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

interface CustomerSessionRepository : ITentRepository!(CustomerSession, CustomerSessionId) {
    CustomerSession findByToken(TenantId tenantId, string token);
    CustomerSession[] findByCustomer(TenantId tenantId, CustomerId customerId);
    CustomerSession[] findActive(TenantId tenantId);
    void revokeByCustomer(TenantId tenantId, CustomerId customerId);
}
