/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryAppDefinitionRepository
    : TenantRepository!(AppDefinition, AppDefinitionId), AppDefinitionRepository {

    mixin TenantRepositoryTemplate!(MemoryAppDefinitionRepository, AppDefinition, AppDefinitionId);

    size_t countByStatus(TenantId tenantId, DefinitionStatus status) {
        return findByStatus(tenantId, status).length;
    }
    AppDefinition[] filterByStatus(AppDefinition[] defs, DefinitionStatus status) {
        return defs.filter!(d => d.status == status).array;
    }
    AppDefinition[] findByStatus(TenantId tenantId, DefinitionStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, DefinitionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByMobileApplication(tenantId, appId).length;
    }
    AppDefinition[] filterByMobileApplication(AppDefinition[] defs, MobileApplicationId appId) {
        return defs.filter!(d => d.applicationId == appId).array;
    }

    AppDefinition[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return filterByMobileApplication(find(tenantId), appId);
    }

    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }
}
///
unittest {
    assert(tenantRepositoryTest(new MemoryAppDefinitionRepository));
}