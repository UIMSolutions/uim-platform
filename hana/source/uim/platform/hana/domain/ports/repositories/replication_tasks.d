/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.replication_tasks;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.replication_task;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface ReplicationTaskRepository {
  ReplicationTask findById(ReplicationTaskId id);
  ReplicationTask[] findByTenant(TenantId tenantId);
  ReplicationTask[] findByInstance(InstanceId instanceId);
  void save(ReplicationTask t);
  void update(ReplicationTask t);
  void remove(ReplicationTaskId id);
  size_t countByTenant(TenantId tenantId);
}
