/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.persistence.memory.replications;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class MemoryReplicationRepository
    : TentRepository!(Replication, ReplicationId), ReplicationRepository {

    size_t countByStatus(TenantId tenantId, ReplicationStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Replication[] findByStatus(TenantId tenantId, ReplicationStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ReplicationStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    Replication[] findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        return findByTenant(tenantId).filter!(e => e.businessPartnerId.value == bpId.value).array;
    }

    Replication[] findByTargetSystem(TenantId tenantId, string targetSystem) {
        return findByTenant(tenantId).filter!(e => e.targetSystem == targetSystem).array;
    }

    Replication[] findByBatchId(TenantId tenantId, string batchId) {
        return findByTenant(tenantId).filter!(e => e.batchId == batchId).array;
    }
}
