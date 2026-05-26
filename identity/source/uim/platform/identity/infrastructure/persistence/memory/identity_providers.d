/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.memory.identity_providers;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class MemoryIdentityProviderRepository : TenantRepository!(IdentityProvider, IdentityProviderId), IdentityProviderRepository {
    IdentityProvider findByEntityId(TenantId tenantId, string entityId) {
        foreach (idp; findByTenant(tenantId))
            if (idp.entityId == entityId) return idp;
        return IdentityProvider.init;
    }

    IdentityProvider findDefault(TenantId tenantId) {
        foreach (idp; findByTenant(tenantId))
            if (idp.isDefault) return idp;
        return IdentityProvider.init;
    }

    IdentityProvider[] findByStatus(TenantId tenantId, IdpStatus status) {
        return findByTenant(tenantId).filter!(idp => idp.status == status).array;
    }

    IdentityProvider[] findByType(TenantId tenantId, IdpType type_) {
        return findByTenant(tenantId).filter!(idp => idp.type_ == type_).array;
    }
}
