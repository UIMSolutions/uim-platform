/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.system_registrations;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.system_registration;
// import uim.platform.appevents.domain.repositories.system_registrations;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.domain.enums.system_type;
// import uim.platform.appevents.domain.enums.system_status;
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.appevents;

// mixin(ShowModule!());

@safe:

class MemorySystemRegistrationRepository
    : TenantRepository!(SystemRegistration, SystemRegistrationId)
    , SystemRegistrationRepository
{
    override SystemRegistration[] findByFormation(TenantId tenantId, FormationId formationId) {
        return findByTenant(tenantId).filter!(r => r.formationId.value == formationId.value).array;
    }

    override SystemRegistration[] findBySystemType(TenantId tenantId, SystemType systemType) {
        return findByTenant(tenantId).filter!(r => r.systemType == systemType).array;
    }

    override SystemRegistration[] findByStatus(TenantId tenantId, SystemStatus status) {
        return findByTenant(tenantId).filter!(r => r.status == status).array;
    }
}
