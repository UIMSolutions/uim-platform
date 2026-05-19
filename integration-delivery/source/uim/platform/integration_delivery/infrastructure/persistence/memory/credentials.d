/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.persistence.memory.credentials;

import uim.platform.integration_delivery;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryCredentialRepository : TenantRepository!(Credential, CredentialId), CredentialRepository {
    Credential[] findByStatus(TenantId tenantId, CredentialStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    Credential[] findByType(TenantId tenantId, CredentialType type) {
        return findByTenant(tenantId).filter!(c => c.credentialType == type).array;
    }

    bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(c => c.name == name);
    }
}
