/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.mobile_applications;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: register and maintain mobile applications.
interface IManageMobileApplicationsUseCase {
  MobileApplication[] listMobileApplications(TenantId tenantId);
  MobileApplication[] listByStatus(TenantId tenantId, AppStatus status);
  MobileApplication[] listByPlatform(TenantId tenantId, AppPlatform platform);
  MobileApplication getMobileApplication(TenantId tenantId, MobileApplicationId id);

  UsecaseResult createMobileApplication(MobileApplicationDTO dto);
  UsecaseResult updateMobileApplication(MobileApplicationDTO dto);
  /// Lifecycle change (draft → active → deprecated → archived).
  UsecaseResult setMobileApplicationStatus(TenantId tenantId, MobileApplicationId id, AppStatus status, UserId by);
  UsecaseResult deleteMobileApplication(TenantId tenantId, MobileApplicationId id);
}
