/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.backup_policies;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ManageBackupPoliciesUseCase {
    private BackupPolicyRepository repo;

    this(BackupPolicyRepository repo) { this.repo = repo; }

    BackupPolicy getBackupPolicy(TenantId tenantId, BackupPolicyId id) {
        return repo.findById(tenantId, id);
    }

    BackupPolicy getByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    BackupPolicy[] listBackupPolicies(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createBackupPolicy(BackupPolicyDTO dto) {
        auto e = BackupPolicy(dto.tenantId); //, UserId("test-user"));
        e.id = dto.backupPolicyId;
        e.instanceId = dto.instanceId;
        e.retentionPeriod = dto.retentionPeriod;
        e.backupWindow = dto.backupWindow;
        e.backupLocation = dto.backupLocation;
        e.status = BackupStatus.enabled;

        if (e.instanceId.value.length == 0)
            return CommandResult(false, "", "instanceId is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateBackupPolicy(BackupPolicyDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.backupPolicyId);
        if (existing.isNull)
            return CommandResult(false, "", "Backup policy not found");
        if (dto.retentionPeriod > 0) existing.retentionPeriod = dto.retentionPeriod;
        if (dto.backupWindow.length > 0) existing.backupWindow = dto.backupWindow;
        if (dto.backupLocation.length > 0) existing.backupLocation = dto.backupLocation;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteBackupPolicy(TenantId tenantId, BackupPolicyId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Backup policy not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
