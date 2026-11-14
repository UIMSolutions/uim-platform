/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: build and release app versions.
interface IManageAppVersionsUseCase {
  AppVersion[] listAppVersions(TenantId tenantId);
  AppVersion[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
  AppVersion[] listByStatus(TenantId tenantId, AppVersionStatus status);
  AppVersion getAppVersion(TenantId tenantId, AppVersionId id);

  UsecaseResult createAppVersion(AppVersionDTO dto);
  UsecaseResult updateAppVersion(AppVersionDTO dto);
  /// Release a version. Requires a published app definition.
  UsecaseResult publishAppVersion(TenantId tenantId, AppVersionId id, UserId by);
  UsecaseResult withdrawAppVersion(TenantId tenantId, AppVersionId id, UserId by);
  UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id);
}
