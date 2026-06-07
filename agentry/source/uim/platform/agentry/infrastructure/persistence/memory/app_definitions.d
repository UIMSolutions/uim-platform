/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.app_definitions;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

class MemoryAppDefinitionRepository
    : TenantRepository!(AppDefinition, AppDefinitionId), AppDefinitionRepository {

    AppDefinition[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByTenant(tenantId).filter!(d => d.mobileApplicationId == appId).array;
    }

    AppDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status) {
        return findByTenant(tenantId).filter!(d => d.status == status).array;
    }

    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }
}
