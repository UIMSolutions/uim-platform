/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.persistence.repositories.mta_operations;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

class MemoryMtaOperationRepository : TenantRepository!(MtaOperation, MtaOperationId), MtaOperationRepository {

    size_t countByMta(TenantId tenantId, string mtaId) {
        return findByMtaId(tenantId, mtaId).length;
    }

    MtaOperation[] filterByMtaId(MtaOperation[] operations, string mtaId) {
        return operations.filter!(op => op.mtaId == mtaId).array;
    }

    /// Find all operations for a given MTA application ID
    MtaOperation[] findByMtaId(TenantId tenantId, string mtaId) {
        return filterByMtaId(findByTenant(tenantId), mtaId);
    }

    void removeByMtaId(TenantId tenantId, string mtaId) {
        findByMtaId(tenantId, mtaId).each!(op => remove(op));
    }

    size_t countByStatus(TenantId tenantId, OperationStatus status) {
        return findByStatus(tenantId, status).length;
    }

    MtaOperation[] filterByStatus(MtaOperation[] operations, OperationStatus status) {
        return operations.filter!(op => op.operationStatus == status).array;
    }

    /// Find all operations with a given status
    MtaOperation[] findByStatus(TenantId tenantId, OperationStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, OperationStatus status) {
        findByStatus(tenantId, status).each!(op => remove(op));
    }
}
