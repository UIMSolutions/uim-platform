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

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageBackupsUseCase { // TODO: UIMUseCase {
  private BackupRepository repo;

  this(BackupRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateBackupRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Backup ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Backup already exists");

    Backup b;
    b.id = r.id;
    b.tenantId = r.tenantId;
    b.instanceId = r.instanceId;
    b.name = r.name;
    b.status = BackupStatus.scheduled;
    b.destination = r.destination;
    b.encrypted = r.encrypted;

    b.schedule.cronExpression = r.cronExpression;
    b.schedule.retentionDays = r.retentionDays;
    b.schedule.enabled = true;

    import core.time : MonoTime;
    b.createdAt = MonoTime.currTime.ticks;

    repo.save(b);
    return CommandResult(true, b.id.value, "");
  }

  Backup getById(BackupId id) {
    return repo.findById(id);
  }

  Backup[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateBackupRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Backup not found");

    auto existing = repo.findById(r.id);
    existing.name = r.name;
    existing.destination = r.destination;
    existing.schedule.cronExpression = r.cronExpression;
    existing.schedule.retentionDays = r.retentionDays;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult remove(BackupId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Backup not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
