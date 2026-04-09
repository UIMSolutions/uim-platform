/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.task_chains;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.task_chain;
import uim.platform.datasphere.domain.ports.repositories.task_chains;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageTaskChainsUseCase : UIMUseCase {
  private TaskChainRepository repo;

  this(TaskChainRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateTaskChainRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Task chain name is required");
    if (r.spaceid.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID().to!string;

    TaskChain tc;
    tc.id = randomUUID();
    tc.tenantId = r.tenantId;
    tc.spaceId = r.spaceId;
    tc.name = r.name;
    tc.description = r.description;
    tc.status = TaskStatus.scheduled;
    tc.scheduleExpression = r.scheduleExpression;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    tc.createdAt = now;
    tc.modifiedAt = now;

    repo.save(tc);
    return CommandResult(true, tc.id, "");
  }

  TaskChain get_(TaskChainId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  TaskChain[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult patch(PatchTaskChainRequest r) {
    auto existing = repo.findById(r.taskChainId, r.spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task chain not found");

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(TaskChainId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task chain not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id.toString, "");
  }
}
