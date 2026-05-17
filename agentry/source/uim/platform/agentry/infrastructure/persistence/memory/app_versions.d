/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryAppVersionRepository
    : TenantRepository!(AppVersion, AppVersionId), AppVersionRepository {

    AppVersion[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByTenant(tenantId).filter!(v => v.mobileApplicationId == appId).array;
    }

    AppVersion[] findByStatus(TenantId tenantId, AppVersionStatus status) {
        return findByTenant(tenantId).filter!(v => v.status == status).array;
    }

    AppVersion[] findByDefinition(TenantId tenantId, AppDefinitionId definitionId) {
        return findByTenant(tenantId).filter!(v => v.definitionId == definitionId).array;
    }

    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }
}
