/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.persistence.memory.mta_operation_repo;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

class MemoryMtaOperationRepository
    : TenantRepository!(MtaOperation, MtaOperationId),
      MtaOperationRepository
{
    /// Find all operations for a given MTA application ID
    MtaOperation[] findByMtaId(TenantId tenantId, string mtaId) {
        MtaOperation[] result;
        foreach (op; findByTenant(tenantId))
            if (op.mtaId == mtaId) result ~= op;
        return result;
    }

    /// Find all operations with a given status
    MtaOperation[] findByStatus(TenantId tenantId, OperationStatus status) {
        MtaOperation[] result;
        foreach (op; findByTenant(tenantId))
            if (op.operationStatus == status) result ~= op;
        return result;
    }
}
