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
class MemoryReplicationTaskRepository : ReplicationTaskRepository {
  private ReplicationTask[] store;

  ReplicationTask findById(ReplicationTaskId id) {
    foreach (t; store) {
      if (t.id == id)
        return t;
    }
    return ReplicationTask.init;
  }

  ReplicationTask[] findByTenant(TenantId tenantId) {
    return store.filter!(t => t.tenantId == tenantId).array;
  }

  ReplicationTask[] findByInstance(InstanceId instanceId) {
    return store.filter!(t => t.instanceId == instanceId).array;
  }

  void save(ReplicationTask t) {
    store ~= t;
  }

  void update(ReplicationTask t) {
    foreach (existing; store) {
      if (existing.id == t.id) {
        existing = t;
        return;
      }
    }
  }

  void remove(ReplicationTaskId id) {
    store = store.filter!(t => t.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.filter!(t => t.tenantId == tenantId).array.length;
  }
}
