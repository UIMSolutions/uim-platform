/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryTrustedCertificateRepository : TenantRepository!(TrustedCertificate, TrustedCertificateId), TrustedCertificateRepository {

    size_t countByCustomDomain(TenantId tenantId, CustomDomainId domainId) {
        return findByCustomDomain(tenantId, domainId).length;
    }

    TrustedCertificate[] filterByCustomDomain(TrustedCertificate[] certs, CustomDomainId domainId) {
        return certs.filter!(c => c.customDomainId == domainId).array;
    }

    TrustedCertificate[] findByCustomDomain(TenantId tenantId, CustomDomainId domainId) {
        return filterByCustomDomain(findByTenant(tenantId), domainId);
    }

    void removeByCustomDomain(TenantId tenantId, CustomDomainId domainId) {
        findByCustomDomain(tenantId, domainId).each!(c => remove(c));
    }

}
