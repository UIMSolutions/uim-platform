/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.usecases.manage.replications;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class ManageReplicationsUseCase {
    private ReplicationRepository repo;

    this(ReplicationRepository repo) {
        this.repo = repo;
    }

    Replication getReplication(TenantId tenantId, ReplicationId id) {
        return repo.findById(tenantId, id);
    }

    Replication[] listReplications(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Replication[] listByStatus(TenantId tenantId, ReplicationStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Replication[] listByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        return repo.findByBusinessPartner(tenantId, bpId);
    }

    Replication[] listByTargetSystem(TenantId tenantId, string targetSystem) {
        return repo.findByTargetSystem(tenantId, targetSystem);
    }

    CommandResult createReplication(ReplicationDTO dto) {
        Replication rep;
        rep.initEntity(dto.tenantId, dto.triggeredBy);
        rep.id = dto.replicationId;
        rep.businessPartnerId = dto.businessPartnerId;
        rep.targetSystem = dto.targetSystem;
        rep.targetSystemType = dto.targetSystemType;
        rep.scheduledAt = dto.scheduledAt;
        rep.replicatedFields = dto.replicatedFields;
        rep.maxRetries = dto.maxRetries > 0 ? dto.maxRetries : 3;
        rep.correlationId = dto.correlationId;
        rep.batchId = dto.batchId;
        rep.triggeredBy = dto.triggeredBy;
        rep.status = ReplicationStatus.pending;
        rep.retryCount = 0;

        if (!MasterdataGovernanceValidator.isValidReplication(rep))
            return CommandResult(false, "", "Invalid replication data");

        repo.save(rep);
        return CommandResult(true, rep.id.value, "");
    }

    CommandResult cancelReplication(TenantId tenantId, ReplicationId id) {
        auto rep = repo.findById(tenantId, id);
        if (rep.isNull)
            return CommandResult(false, "", "Replication not found");
        if (rep.status == ReplicationStatus.completed || rep.status == ReplicationStatus.cancelled)
            return CommandResult(false, "", "Replication cannot be cancelled in current status");

        rep.status = ReplicationStatus.cancelled;
        repo.update(rep);
        return CommandResult(true, rep.id.value, "");
    }

    CommandResult deleteReplication(TenantId tenantId, ReplicationId id) {
        auto rep = repo.findById(tenantId, id);
        if (rep.isNull)
            return CommandResult(false, "", "Replication not found");

        repo.remove(rep);
        return CommandResult(true, rep.id.value, "");
    }
}
