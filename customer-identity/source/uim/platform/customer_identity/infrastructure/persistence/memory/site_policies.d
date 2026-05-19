/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.memory.site_policies;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class MemorySitePolicyRepository : TenantRepository!(SitePolicy, SitePolicyId), SitePolicyRepository {

    SitePolicy[] findByType(TenantId tenantId, PolicyType policyType) {
        return findByTenant(tenantId).filter!(sp => sp.policyType == policyType).array;
    }

    SitePolicy findActiveByType(TenantId tenantId, PolicyType policyType) {
        auto items = findByType(tenantId, policyType);
        return items.length > 0 ? items[0] : SitePolicy.init;
    }
}
