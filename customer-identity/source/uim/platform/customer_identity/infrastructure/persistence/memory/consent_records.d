/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.memory.consent_records;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class MemoryConsentRecordRepository : TenantRepository!(ConsentRecord, ConsentRecordId), ConsentRecordRepository {

    ConsentRecord[] findByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByTenant(tenantId).filter!(cr => cr.customerId.value == customerId.value).array;
    }

    ConsentRecord[] findByType(TenantId tenantId, ConsentType consentType) {
        return findByTenant(tenantId).filter!(cr => cr.consentType == consentType).array;
    }

    ConsentRecord[] findGrantedByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByCustomer(tenantId, customerId).filter!(cr => cr.granted).array;
    }

    void revokeByCustomer(TenantId tenantId, CustomerId customerId) {
        
        auto records = findByCustomer(tenantId, customerId);
        foreach (ref cr; records) {
            cr.granted = false;
            cr.revokedAt = MonoTime.currTime.ticks;
            update(cr);
        }
    }
}
