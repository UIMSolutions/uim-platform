/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.repositories.social_identities;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class MemorySocialIdentityRepository : TenantRepository!(SocialIdentity, SocialIdentityId), SocialIdentityRepository {

    SocialIdentity[] findByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByTenant(tenantId).filter!(si => si.customerId.value == customerId.value).array;
    }

    SocialIdentity findByProvider(TenantId tenantId, LoginProvider provider, string providerUserId) {
        auto items = findByTenant(tenantId).filter!(si => si.provider == provider && si.providerUserId == providerUserId).array;
        return items.length > 0 ? items[0] : SocialIdentity.init;
    }

    void unlinkByCustomerAndProvider(TenantId tenantId, CustomerId customerId, LoginProvider provider) {
        auto items = findByCustomer(tenantId, customerId).filter!(si => si.provider == provider).array;
        foreach (ref si; items) {
            si.status = SocialIdentityStatus.unlinked;
            update(si);
        }
    }
}
