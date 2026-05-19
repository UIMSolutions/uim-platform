/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.formations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;
import uim.platform.appevents.domain.repositories.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryFormationRepository
    : TenantRepository!(Formation, FormationId)
    , FormationRepository
{
    override Formation[] findByStatus(TenantId tenantId, FormationStatus status) {
        return findAll(tenantId).filter!(f => f.status == status).array;
    }

    override Formation[] findByGlobalAccount(TenantId tenantId, string globalAccountId) {
        return findAll(tenantId).filter!(f => f.globalAccountId == globalAccountId).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findAll(tenantId).filter!(f => f.name == name).array.length > 0;
    }
}
