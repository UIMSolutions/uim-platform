/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.replication_tasks;
// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.replication_task;
// import uim.platform.hana.domain.ports.repositories.replication_tasks;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageReplicationTasksUseCase { // TODO: UIMUseCase {
  private ReplicationTaskRepository repo;

  this(ReplicationTaskRepository repo) {
    this.repo = repo;
  }

  CommandResult createReplicationTask(CreateReplicationTaskRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Replication task ID and name are required");

    if (repo.existsById(r.tenantId, r.replicationTaskId))
      return CommandResult(false, "", "Replication task already exists");

    ReplicationTask t;  
    t.initEntity(r.tenantId);
    t.id = r.id;
    t.instanceId = r.instanceId;
    t.name = r.name;
    t.description = r.description;
    t.status = ReplicationTaskStatus.inactive;
    t.sourceConnectionId = r.sourceConnectionId;
    t.targetConnectionId = r.targetConnectionId;
    t.scheduleExpression = r.scheduleExpression;

    repo.save(t);
    return CommandResult(true, t.id.value, "");
  }

  ReplicationTask getReplicationTask(ReplicationTaskId id) {
    return repo.findById(tenantId, id);
  }

  ReplicationTask[] listReplicationTasks(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateReplicationTask(UpdateReplicationTaskRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.isNull)
      return CommandResult(false, "", "Replication task not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.scheduleExpression = r.scheduleExpression;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteReplicationTask(ReplicationTaskId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Replication task not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countReplicationTasks(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
