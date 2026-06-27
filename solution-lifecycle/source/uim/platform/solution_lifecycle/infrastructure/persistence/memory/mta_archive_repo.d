/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.persistence.memory.mta_archive_repo;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

class MemoryMtaArchiveRepository
    : TentRepository!(MtaArchive, MtaArchiveId),
      MtaArchiveRepository
{
    /// Find archives by MTA application ID
    MtaArchive[] findByMtaId(TenantId tenantId, string mtaId) {
        MtaArchive[] result;
        foreach (a; findByTenant(tenantId))
            if (a.mtaId == mtaId) result ~= a;
        return result;
    }
}
