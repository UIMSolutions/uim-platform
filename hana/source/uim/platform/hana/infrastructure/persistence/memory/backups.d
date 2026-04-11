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
class MemoryBackupRepository : BackupRepository {
  private Backup[] store;

  Backup findById(BackupId id) {
    foreach (b; store) {
      if (b.id == id)
        return b;
    }
    return Backup.init;
  }

  Backup[] findByTenant(TenantId tenantId) {
    return store.filter!(b => b.tenantId == tenantId).array;
  }

  Backup[] findByInstance(InstanceId instanceId) {
    return store.filter!(b => b.instanceId == instanceId).array;
  }

  void save(Backup b) {
    store ~= b;
  }

  void update(Backup b) {
    foreach (existing; store) {
      if (existing.id == b.id) {
        existing = b;
        return;
      }
    }
  }

  void remove(BackupId id) {
    store = store.filter!(b => b.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.filter!(b => b.tenantId == tenantId).array.length;
  }
}
