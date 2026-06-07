/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.repositories.screen_sets;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

interface ScreenSetRepository : ITenantRepository!(ScreenSet, ScreenSetId) {
    ScreenSet[] findByFlowType(TenantId tenantId, ScreenSetFlowType flowType);
    ScreenSet[] findActive(TenantId tenantId);
    ScreenSet findByNameAndLocale(TenantId tenantId, string name, string locale);
}
