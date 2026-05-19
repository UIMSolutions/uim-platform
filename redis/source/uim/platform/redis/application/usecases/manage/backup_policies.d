/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.backup_policies;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ManageBackupPoliciesUseCase {
    private BackupPolicyRepository repo;

    this(BackupPolicyRepository repo) { this.repo = repo; }

    BackupPolicy getBackupPolicy(TenantId tenantId, BackupPolicyId id) {
        return repo.findById(tenantId, id);
    }

    BackupPolicy[] listBackupPolicies(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    BackupPolicy getByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createBackupPolicy(BackupPolicyDTO dto) {
        auto existing = repo.findByInstance(dto.tenantId, dto.instanceId);
        if (!existing.isNull)
            return CommandResult(false, "", "Backup policy already exists for this instance");

        BackupPolicy e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.backupPolicyId;
        e.instanceId = dto.instanceId;
        e.enabled = dto.enabled;
        e.intervalHours = dto.intervalHours;
        e.retentionDays = dto.retentionDays;
        e.backupLocation = dto.backupLocation;
        e.status = dto.enabled ? BackupStatus.enabled : BackupStatus.disabled_;

        if (!RedisValidator.isValidBackupPolicy(e))
            return CommandResult(false, "", "Invalid backup policy: instanceId, intervalHours and retentionDays required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateBackupPolicy(BackupPolicyDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.backupPolicyId);
        if (existing.isNull)
            return CommandResult(false, "", "Backup policy not found");

        existing.enabled = dto.enabled;
        if (dto.intervalHours > 0) existing.intervalHours = dto.intervalHours;
        if (dto.retentionDays > 0) existing.retentionDays = dto.retentionDays;
        if (dto.backupLocation.length > 0) existing.backupLocation = dto.backupLocation;
        existing.status = dto.enabled ? BackupStatus.enabled : BackupStatus.disabled_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteBackupPolicy(TenantId tenantId, BackupPolicyId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Backup policy not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
