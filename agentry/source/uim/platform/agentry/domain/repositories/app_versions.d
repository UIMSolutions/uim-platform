/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface AppVersionRepository : ITentRepository!(AppVersion, AppVersionId) {
    AppVersion[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    AppVersion[] findByStatus(TenantId tenantId, AppVersionStatus status);
    AppVersion[] findByDefinition(TenantId tenantId, AppDefinitionId definitionId);
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId);
}
