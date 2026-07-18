/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.persistence.memory.mtas;_repo;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

class MemoryMtaRepository
    : TenantRepository!(Mta, MtaId),
      MtaRepository
{
    /// Find all MTAs for a tenant with a given MTA application ID
    Mta[] findByMtaId(TenantId tenantId, string mtaId) {
        Mta[] result;
        foreach (m; findByTenant(tenantId))
            if (m.mtaId == mtaId) result ~= m;
        return result;
    }

    /// Find all MTAs for a tenant by solution type
    Mta[] findBySolutionType(TenantId tenantId, SolutionType solType) {
        Mta[] result;
        foreach (m; findByTenant(tenantId))
            if (m.solutionType == solType) result ~= m;
        return result;
    }
}
