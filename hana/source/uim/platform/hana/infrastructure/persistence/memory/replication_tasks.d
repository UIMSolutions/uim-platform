/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.replication_tasks;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.replication_task;
// import uim.platform.hana.domain.ports.repositories.replication_tasks;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryReplicationTaskRepository : TenantRepository!(ReplicationTask, ReplicationTaskId), ReplicationTaskRepository {

  size_t countByInstance(InstanceId instanceId) {
    return findByInstance(instanceId).length;
  }
  ReplicationTask[] filterByInstance(RReplicationTask[] tasks, InstanceId instanceId) {
    return tasks.filter!(t => t.instanceId == instanceId).array;
  }
  ReplicationTask[] findByInstance(InstanceId instanceId) {
    return findAll().filter!(t => t.instanceId == instanceId).array;
  }
  void deleteByInstance(InstanceId instanceId) {
    findByInstance(instanceId).each!(t => remove(t));
  }
}
