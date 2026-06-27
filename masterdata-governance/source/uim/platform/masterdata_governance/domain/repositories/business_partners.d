/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.repositories.business_partners;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

interface BusinessPartnerRepository : ITentRepository!(BusinessPartner, BusinessPartnerId) {

    BusinessPartner findByBpNumber(TenantId tenantId, string bpNumber);

    size_t countByCategory(TenantId tenantId, BPCategory category);
    BusinessPartner[] findByCategory(TenantId tenantId, BPCategory category);
    void removeByCategory(TenantId tenantId, BPCategory category);

    size_t countByStatus(TenantId tenantId, BPStatus status);
    BusinessPartner[] findByStatus(TenantId tenantId, BPStatus status);
    void removeByStatus(TenantId tenantId, BPStatus status);

    BusinessPartner[] findByValidationStatus(TenantId tenantId, ValidationStatus validationStatus);
    BusinessPartner[] findByCountry(TenantId tenantId, string country);
    BusinessPartner[] searchByName(TenantId tenantId, string searchTerm);
}
