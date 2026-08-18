/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.mobile_apps;
// import uim.platform.mobile.domain.ports.repositories.mobile_apps;
// import uim.platform.mobile.domain.entities.mobile_app;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface IManageMobileAppsUseCase { 

    UsecaseResult createMobileApp(CreateMobileAppRequest r);

    UsecaseResult updateMobileApp(UpdateMobileAppRequest r);

    MobileApp getMobileApp(TenantId tenantId, MobileAppId id);

    MobileApp[] listMobileApps(TenantId tenantId);

    UsecaseResult deleteMobileApp(TenantId tenantId, MobileAppId id);

    size_t countMobileAppsByTenant(TenantId tenantId);

}
