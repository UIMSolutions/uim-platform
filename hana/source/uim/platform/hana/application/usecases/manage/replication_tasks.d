/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.replication_tasks;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.replication_task;
import uim.platform.hana.domain.ports.repositories.replication_tasks;
import uim.platform.hana.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageReplicationTasksUseCase : UIMUseCase {
  private ReplicationTaskRepository repo;

  this(ReplicationTaskRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateReplicationTaskRequest r) {
    if (r.id.length == 0 || r.name.length == 0)
      return CommandResult(false, "", "Replication task ID and name are required");

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Replication task already exists");

    ReplicationTask t;
    t.id = r.id;
    t.tenantId = r.tenantId;
    t.instanceId = r.instanceId;
    t.name = r.name;
    t.description = r.description;
    t.status = ReplicationTaskStatus.inactive;
    t.sourceConnectionId = r.sourceConnectionId;
    t.targetConnectionId = r.targetConnectionId;
    t.scheduleExpression = r.scheduleExpression;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    t.createdAt = now;
    t.modifiedAt = now;

    repo.save(t);
    return CommandResult(true, t.id, "");
  }

  ReplicationTask get_(ReplicationTaskId id) {
    return repo.findById(id);
  }

  ReplicationTask[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateReplicationTaskRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.length == 0)
      return CommandResult(false, "", "Replication task not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.scheduleExpression = r.scheduleExpression;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(ReplicationTaskId id) {
    auto existing = repo.findById(id);
    if (existing.id.length == 0)
      return CommandResult(false, "", "Replication task not found");

    repo.remove(id);
    return CommandResult(true, id, "");
  }

  long count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
