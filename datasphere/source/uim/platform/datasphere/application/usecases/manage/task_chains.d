/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.task_chains;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.task_chain;
// import uim.platform.datasphere.domain.ports.repositories.task_chains;
// import uim.platform.datasphere.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageTaskChainsUseCase { // TODO: UIMUseCase {
  private TaskChainRepository repo;

  this(TaskChainRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateTaskChainRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Task chain name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID();

    TaskChain tc;
    tc.id = id;
    tc.tenantId = r.tenantId;
    tc.spaceId = r.spaceId;
    tc.name = r.name;
    tc.description = r.description;
    tc.status = TaskStatus.scheduled;
    tc.scheduleExpression = r.scheduleExpression;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    tc.createdAt = now;
    tc.updatedAt = now;

    repo.save(tc);
    return CommandResult(true, tc.id.value, "");
  }

  TaskChain getById(SpaceId spaceId, TaskChainId id) {
    return repo.findById(spaceId, id);
  }

  TaskChain[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult patch(PatchTaskChainRequest r) {
    auto existing = repo.findById(r.spaceId, r.taskChainId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task chain not found");

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult remove(SpaceId spaceId, TaskChainId id) {
    auto existing = repo.findById(spaceId, id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Task chain not found");

    repo.remove(spaceId, id);
    return CommandResult(true, id.value, "");
  }
}
