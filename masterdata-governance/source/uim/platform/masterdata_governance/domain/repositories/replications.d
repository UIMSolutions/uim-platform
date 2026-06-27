/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.repositories.replications;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

interface ReplicationRepository : ITenantRepository!(Replication, ReplicationId) {

    size_t countByStatus(TenantId tenantId, ReplicationStatus status);
    Replication[] findByStatus(TenantId tenantId, ReplicationStatus status);
    void removeByStatus(TenantId tenantId, ReplicationStatus status);

    Replication[] findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId);
    Replication[] findByTargetSystem(TenantId tenantId, string targetSystem);
    Replication[] findByBatchId(TenantId tenantId, string batchId);
}
