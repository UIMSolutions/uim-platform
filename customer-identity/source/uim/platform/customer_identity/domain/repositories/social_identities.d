/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.social_identities;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

interface SocialIdentityRepository : ITenantRepository!(SocialIdentity, SocialIdentityId) {
    SocialIdentity[] findByCustomer(TenantId tenantId, CustomerId customerId);
    SocialIdentity findByProvider(TenantId tenantId, LoginProvider provider, string providerUserId);
    void unlinkByCustomerAndProvider(TenantId tenantId, CustomerId customerId, LoginProvider provider);
}
