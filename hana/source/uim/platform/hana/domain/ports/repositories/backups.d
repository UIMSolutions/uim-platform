/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.backups;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.backup;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface BackupRepository {
  Backup findById(BackupId id);
  Backup[] findByTenant(TenantId tenantId);
  Backup[] findByInstance(InstanceId instanceId);
  void save(Backup b);
  void update(Backup b);
  void remove(BackupId id);
  long countByTenant(TenantId tenantId);
}
