/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.backups;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.backup;
// import uim.platform.hana.domain.ports.repositories.backups;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryBackupRepository : TenantRepository!(Backup, BackupId), BackupRepository {

  size_t countByInstance(DatabaseInstanceId instanceId) {
    return findByInstance(instanceId).length;
  }
  Backup[] filterByInstance(Backup[] backups, DatabaseInstanceId instanceId) {
    return backups.filter!(b => b.instanceId == instanceId).array;
  }
  Backup[] findByInstance(DatabaseInstanceId instanceId) {
    return filterByInstance(findAll(), instanceId);
  }
  void removeByInstance(DatabaseInstanceId instanceId) {
    findByInstance(instanceId).each!(b => remove(b.id));
  }

}
