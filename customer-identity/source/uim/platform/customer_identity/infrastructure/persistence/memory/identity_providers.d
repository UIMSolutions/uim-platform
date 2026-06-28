/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.memory.identity_providers;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class MemoryIdentityProviderRepository : TenantRepository!(IdentityProvider, IdentityProviderId), IdentityProviderRepository {

    IdentityProvider[] findByType(TenantId tenantId, IdentityProviderType providerType) {
        return find(tenantId).filter!(ip => ip.providerType == providerType).array;
    }

    IdentityProvider[] findActive(TenantId tenantId) {
        return find(tenantId).filter!(ip => ip.status == IdentityProviderStatus.active).array;
    }

    IdentityProvider findByClient(TenantId tenantId, string clientId) {
        auto items = find(tenantId).filter!(ip => ip.clientId == clientId).array;
        return items.length > 0 ? items[0] : IdentityProvider.init;
    }
}
