/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.ports.usecases.replications;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface IManageReplicationsUseCase {

    Replication getReplication(TenantId tenantId, ReplicationId id);
    Replication[] listReplications(TenantId tenantId);
    Replication[] listReplications(TenantId tenantId, ReplicationStatus status);
    Replication[] listReplications(TenantId tenantId, BusinessPartnerId bpId);
    Replication[] listReplications(TenantId tenantId, string targetSystem);
    CommandResult createReplication(ReplicationDTO dto);
    CommandResult cancelReplication(TenantId tenantId, ReplicationId id);
    CommandResult deleteReplication(TenantId tenantId, ReplicationId id);
}
