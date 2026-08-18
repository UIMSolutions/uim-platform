/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.push_registrations;
// import uim.platform.mobile.domain.ports.repositories.push_registrations;
// import uim.platform.mobile.domain.entities.push_registration;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManagePushRegistrationsUseCase { 

    UsecaseResult registerPushRegistration(CreatePushRegistrationRequest r);

    PushRegistration getPushRegistration(TenantId tenantId, PushRegistrationId id);

    PushRegistration[] listPushRegistrations(TenantId tenantId);

    PushRegistration[] listPushRegistrations(TenantId tenantId, MobileAppId appId);

    PushRegistration[] listPushRegistrations(TenantId tenantId, MobileAppId appId, string topic);

    UsecaseResult deletePushRegistration(TenantId tenantId, PushRegistrationId id);

    size_t countPushRegistrationsByApp(TenantId tenantId, MobileAppId appId);

}
