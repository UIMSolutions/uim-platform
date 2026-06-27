/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.site_policies;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

interface SitePolicyRepository : ITentRepository!(SitePolicy, SitePolicyId) {
    SitePolicy[] findByType(TenantId tenantId, PolicyType policyType);
    SitePolicy findActiveByType(TenantId tenantId, PolicyType policyType);
}
