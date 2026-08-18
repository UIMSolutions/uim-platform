/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.backups;
// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.backup;
// import uim.platform.hana.domain.ports.repositories.backups;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageBackupsUseCase {
  protected IBackupRepository repo;

  this(IBackupRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createBackup(CreateBackupRequest r) {
    if (r.isNull || r.name.isEmpty)
      return UsecaseResult(false, "", "Backup ID and name are required");

    auto existing = repo.findById(r.tenantId, r.id);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Backup already exists");

    auto b = Backup(r.tenantId, r.id);
    b.instanceId = r.instanceId;
    b.name = r.name;
    b.status = BackupStatus.scheduled;
    b.destination = r.destination;
    b.encrypted = r.encrypted;

    b.schedule.cronExpression = r.cronExpression;
    b.schedule.retentionDays = r.retentionDays;
    b.schedule.enabled = true;


    repo.save(b);
    return UsecaseResult(true, b.id.value, "");
  }

  Backup getBackup(TenantId tenantId, BackupId id) {
    return repo.findById(tenantId, id);
  }

  Backup[] listBackups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateBackup(UpdateBackupRequest r) {
    auto existing = repo.findById(r.tenantId, r.backupId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Backup not found");

    existing.name = r.name;
    existing.destination = r.destination;
    existing.schedule.cronExpression = r.cronExpression;
    existing.schedule.retentionDays = r.retentionDays;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult deleteBackup(TenantId tenantId, BackupId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Backup not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t countBackups(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
