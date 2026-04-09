/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

interface CertificateRepository {
    Certificate findById(CertificateId id);
    Certificate[] findByTenant(TenantId tenantId);
    Certificate[] findByKey(PrivateKeyId keyId);
    Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp);
    void save(Certificate c);
    void update(Certificate c);
    void remove(CertificateId id);
    size_t countByTenant(TenantId tenantId);
}
