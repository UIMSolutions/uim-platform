/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.persistence.memory.business_partners;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class MemoryBusinessPartnerRepository
    : TenantRepository!(BusinessPartner, BusinessPartnerId), BusinessPartnerRepository {

    BusinessPartner findByBpNumber(TenantId tenantId, string bpNumber) {
        auto all = findByTenant(tenantId);
        foreach (bp; all)
            if (bp.bpNumber == bpNumber) return bp;
        return BusinessPartner.init;
    }

    size_t countByCategory(TenantId tenantId, BPCategory category) {
        return findByCategory(tenantId, category).length;
    }

    BusinessPartner[] findByCategory(TenantId tenantId, BPCategory category) {
        return findByTenant(tenantId).filter!(e => e.category == category).array;
    }

    void removeByCategory(TenantId tenantId, BPCategory category) {
        findByCategory(tenantId, category).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, BPStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BusinessPartner[] findByStatus(TenantId tenantId, BPStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, BPStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    BusinessPartner[] findByValidationStatus(TenantId tenantId, ValidationStatus validationStatus) {
        return findByTenant(tenantId).filter!(e => e.validationStatus == validationStatus).array;
    }

    BusinessPartner[] findByCountry(TenantId tenantId, string country) {
        return findByTenant(tenantId).filter!(e => e.country == country).array;
    }

    BusinessPartner[] searchByName(TenantId tenantId, string searchTerm) {
        import std.string : toLower, indexOf;
        auto term = searchTerm.toLower;
        return findByTenant(tenantId).filter!(e =>
            e.organizationName.toLower.indexOf(term) >= 0 ||
            e.firstName.toLower.indexOf(term) >= 0 ||
            e.lastName.toLower.indexOf(term) >= 0 ||
            e.searchTerms.toLower.indexOf(term) >= 0
        ).array;
    }
}
