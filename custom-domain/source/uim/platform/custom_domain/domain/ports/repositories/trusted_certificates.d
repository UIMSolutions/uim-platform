/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface TrustedCertificateRepository {
    TrustedCertificate findById(TrustedCertificateId id);
    TrustedCertificate[] findByTenant(TenantId tenantId);
    TrustedCertificate[] findByDomain(CustomDomainId domainId);
    void save(TrustedCertificate c);
    void update(TrustedCertificate c);
    void remove(TrustedCertificateId id);
    long countByTenant(TenantId tenantId);
}
