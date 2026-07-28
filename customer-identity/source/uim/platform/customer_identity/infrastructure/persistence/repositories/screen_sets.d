/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.persistence.repositories.screen_sets;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class MemoryScreenSetRepository : TenantRepository!(ScreenSet, ScreenSetId), ScreenSetRepository {

    ScreenSet[] findByFlowType(TenantId tenantId, ScreenSetFlowType flowType) {
        return findByTenant(tenantId).filter!(ss => ss.flowType == flowType).array;
    }

    ScreenSet[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(ss => ss.status == ScreenSetStatus.active).array;
    }

    ScreenSet findByNameAndLocale(TenantId tenantId, string name, string locale) {
        auto items = findByTenant(tenantId).filter!(ss => ss.name == name && ss.locale == locale).array;
        return items.length > 0 ? items[0] : ScreenSet.init;
    }
}
