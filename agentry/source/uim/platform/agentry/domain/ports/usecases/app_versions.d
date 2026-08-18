/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageAppVersionsUseCase {
    
    AppVersion[] listAppVersions(TenantId tenantId);
    AppVersion getAppVersion(TenantId tenantId, AppVersionId id);
    UsecaseResult createAppVersion(AppVersionDTO dto);
    UsecaseResult updateAppVersion(AppVersionDTO dto);
    UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id);

    AppVersion[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    AppVersion[] listByStatus(TenantId tenantId, AppVersionStatus status);

}

