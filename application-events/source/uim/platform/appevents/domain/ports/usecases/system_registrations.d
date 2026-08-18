/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.system_registrations;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageSystemRegistrationsUseCase {

    SystemRegistration getSystemRegistration(TenantId tenantId, SystemRegistrationId id);
    SystemRegistration[] listSystemRegistrations(TenantId tenantId);
    SystemRegistration[] listByFormation(TenantId tenantId, FormationId formationId);
    UsecaseResult registerSystem(SystemRegistrationDTO dto);
    UsecaseResult deleteSystemRegistration(TenantId tenantId, SystemRegistrationId id);

}
