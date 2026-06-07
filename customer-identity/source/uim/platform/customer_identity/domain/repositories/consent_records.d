/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.consent_records;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

interface ConsentRecordRepository : ITenantRepository!(ConsentRecord, ConsentRecordId) {
    ConsentRecord[] findByCustomer(TenantId tenantId, CustomerId customerId);
    ConsentRecord[] findByType(TenantId tenantId, ConsentType consentType);
    ConsentRecord[] findGrantedByCustomer(TenantId tenantId, CustomerId customerId);
    void revokeByCustomer(TenantId tenantId, CustomerId customerId);
}
