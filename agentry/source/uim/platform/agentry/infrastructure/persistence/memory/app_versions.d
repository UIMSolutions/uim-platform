/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryAppVersionRepository : TenantRepository!(AppVersion, AppVersionId), AppVersionRepository {
    mixin TenantRepositoryTemplate!(MemoryAppVersionRepository, AppVersion, AppVersionId);

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByMobileApplication(tenantId, appId).length;
    }

    AppVersion[] filterByMobileApplication(AppVersion[] versions, MobileApplicationId appId) {
        return versions.filter!(v => v.mobileApplicationId == appId).array;
    }

    AppVersion[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return filterByMobileApplication(find(tenantId), appId);
    }

    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, AppVersionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    AppVersion[] filterByStatus(AppVersion[] versions, AppVersionStatus status) {
        return versions.filter!(v => v.status == status).array;
    }

    AppVersion[] findByStatus(TenantId tenantId, AppVersionStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, AppVersionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByDefinition(TenantId tenantId, AppDefinitionId definitionId) {
        return findByDefinition(tenantId, definitionId).length;
    }

    AppVersion[] filterByDefinition(AppVersion[] versions, AppDefinitionId definitionId) {
        return versions.filter!(v => v.definitionId == definitionId).array;
    }

    AppVersion[] findByDefinition(TenantId tenantId, AppDefinitionId definitionId) {
        return filterByDefinition(find(tenantId), definitionId);
    }

    void removeByDefinition(TenantId tenantId, AppDefinitionId definitionId) {
        findByDefinition(tenantId, definitionId).each!(e => remove(e));
    }
}
///
unittest {
    assert(tenantRepositoryTest(new MemoryAppVersionRepository));
}