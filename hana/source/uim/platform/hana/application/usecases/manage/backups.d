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

// mixin(ShowModule!());

@safe:
class ManageBackupsUseCase { // TODO: UIMUseCase {
  private BackupRepository repo;

  this(BackupRepository repo) {
    this.repo = repo;
  }

  CommandResult createBackup(CreateBackupRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Backup ID and name are required");

    auto existing = repo.findById(r.tenantId, r.id);
    if (!existing.isNull)
      return CommandResult(false, "", "Backup already exists");

    Backup b;
    b.initEntity(r.tenantId);
    b.id = r.id;
    b.instanceId = r.instanceId;
    b.name = r.name;
    b.status = BackupStatus.scheduled;
    b.destination = r.destination;
    b.encrypted = r.encrypted;

    b.schedule.cronExpression = r.cronExpression;
    b.schedule.retentionDays = r.retentionDays;
    b.schedule.enabled = true;


    repo.save(b);
    return CommandResult(true, b.id.value, "");
  }

  Backup getBackup(BackupId id) {
    return repo.findById(tenantId, id);
  }

  Backup[] listBackups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateBackup(UpdateBackupRequest r) {
    auto existing = repo.findById(r.tenantId, r.id);
    if (existing.isNull)
      return CommandResult(false, "", "Backup not found");

    existing.name = r.name;
    existing.destination = r.destination;
    existing.schedule.cronExpression = r.cronExpression;
    existing.schedule.retentionDays = r.retentionDays;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteBackup(BackupId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Backup not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countBackups(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
