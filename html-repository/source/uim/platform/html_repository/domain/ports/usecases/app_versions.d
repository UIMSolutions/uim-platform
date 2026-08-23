/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.app_versions;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface IManageAppVersionsUseCase {

    UsecaseResult createAppVersion(CreateAppVersionRequest r);

    UsecaseResult updateAppVersion(TenantId tenantId, AppVersionId id, UpdateAppVersionRequest r);

    AppVersion getAppVersion(TenantId tenantId, AppVersionId id);

    AppVersion getLatestAppVersion(TenantId tenantId, HtmlAppId appId);

    AppVersion[] listAppVersions(TenantId tenantId, HtmlAppId appId);

    UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id);

    size_t countByApp(TenantId tenantId, HtmlAppId appId);

}
