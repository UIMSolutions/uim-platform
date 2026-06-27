/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.system_registrations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.system_registration;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.system_type;
import uim.platform.appevents.domain.enums.system_status;

@safe:

interface SystemRegistrationRepository : ITenantRepository!(SystemRegistration, SystemRegistrationId) {
    SystemRegistration[] findByFormation(TenantId tenantId, FormationId formationId);
    SystemRegistration[] findBySystemType(TenantId tenantId, SystemType systemType);
    SystemRegistration[] findByStatus(TenantId tenantId, SystemStatus status);
}
