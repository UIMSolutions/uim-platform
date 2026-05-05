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
interface ReplicationTaskRepository : ITenantRepository!(ReplicationTask, ReplicationTaskId) {

  size_t countByInstance(DatabaseInstanceId instanceId);
  ReplicationTask[] findByInstance(DatabaseInstanceId instanceId);
  void removeByInstance(DatabaseInstanceId instanceId);
}
