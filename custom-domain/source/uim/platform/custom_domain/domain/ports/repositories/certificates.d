/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.ports.repositories.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

/// Repository interface for managing TLS certificates associated with custom domains.
interface CertificateRepository : ITenantRepository!(Certificate, CertificateId) {

    size_t countByKey(PrivateKeyId keyId);
    Certificate[] findByKey(PrivateKeyId keyId);
    void removeByKey(PrivateKeyId keyId);

    size_t countExpiring(TenantId tenantId, long beforeTimestamp);
    Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp);
    void removeExpiring(TenantId tenantId, long beforeTimestamp);
    
}
