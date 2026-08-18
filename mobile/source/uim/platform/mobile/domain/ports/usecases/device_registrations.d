/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.device_registrations;
// import uim.platform.mobile.domain.ports.repositories.device_registrations;
// import uim.platform.mobile.domain.entities.device_registration;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageDeviceRegistrationsUseCase { 
    
    UsecaseResult register(RegisterDeviceRequest r);

    UsecaseResult updateStatus(TenantId tenantId, DeviceRegistrationId id, string status);

    DeviceRegistration getDeviceRegistration(TenantId tenantId, DeviceRegistrationId id);

    DeviceRegistration[] listDeviceRegistration(TenantId tenantId);

    DeviceRegistration[] listDeviceRegistration(TenantId tenantId, MobileAppId appId);

    DeviceRegistration[] listByTenant(TenantId tenantId);

    UsecaseResult deleteDeviceRegistration(TenantId tenantId, DeviceRegistrationId id);

    size_t countByApp(TenantId tenantId, MobileAppId appId);

}
