/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.mobile_applications;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageMobileApplicationsUseCase {

    MobileApplication getMobileApplication(TenantId tenantId, MobileApplicationId id);
    MobileApplication[] listMobileApplications(TenantId tenantId);
    MobileApplication[] listByStatus(TenantId tenantId, AppStatus status);
    MobileApplication[] listByPlatform(TenantId tenantId, AppPlatform platform);

    UsecaseResult createMobileApplication(MobileApplicationDTO dto);
    UsecaseResult updateMobileApplication(MobileApplicationDTO dto);
    UsecaseResult deleteMobileApplication(TenantId tenantId, MobileApplicationId id);

}
