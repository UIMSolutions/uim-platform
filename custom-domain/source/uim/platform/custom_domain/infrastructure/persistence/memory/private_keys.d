/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.private_keys;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryPrivateKeyRepository : TenantRepository!(PrivateKey, PrivateKeyId), PrivateKeyRepository {

    size_t countByStatus(TenantId tenantId, KeyStatus status) {
        return findAll().count!(k => k.tenantId == tenantId && k.status == status);
    }

    PrivateKey[] filterByStatus(PrivateKey[] keys, KeyStatus status) {
        return keys.filter!(k => k.status == status).array;
    }

    PrivateKey[] findByStatus(TenantId tenantId, KeyStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, KeyStatus status) {
        findByStatus(tenantId, status).each!(k => remove(k));
    }

}
