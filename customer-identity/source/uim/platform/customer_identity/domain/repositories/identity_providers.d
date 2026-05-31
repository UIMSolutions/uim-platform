/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.identity_providers;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

interface IdentityProviderRepository : ITenantRepository!(IdentityProvider, IdentityProviderId) {
    IdentityProvider[] findByType(TenantId tenantId, IdentityProviderType providerType);
    IdentityProvider[] findActive(TenantId tenantId);
    IdentityProvider findByClient(TenantId tenantId, string clientId);
}
