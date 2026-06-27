/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryCertificateRepository : TenantRepository!(Certificate, CertificateId), CertificateRepository {

    // #region ByKey
    size_t countByKey(TenantId tenantId, PrivateKeyId keyId) {
        return findByKey(tenantId, keyId).length;
    }

    Certificate[] findByKey(TenantId tenantId, PrivateKeyId keyId) {
        // TODO: return findByTenant(tenantId).filter!(c => c.keyId == keyId).array;
        return null;
    }

    void removeByKey(TenantId tenantId, PrivateKeyId keyId) {
        findByKey(tenantId, keyId).each!(c => remove(c));
    }
    // #endregion ByKey

    // #region Expiring
    size_t countExpiring(TenantId tenantId, long beforeTimestamp) {
        return findExpiring(tenantId, beforeTimestamp).length;
    }

    Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp) {
        return findByTenant(tenantId).filter!(c => c.validTo > 0 && c.validTo <= beforeTimestamp)
            .array;
    }

    void removeExpiring(TenantId tenantId, long beforeTimestamp) {
        findExpiring(tenantId, beforeTimestamp).each!(c => remove(c));
    }
    // #endregion Expiring

}
