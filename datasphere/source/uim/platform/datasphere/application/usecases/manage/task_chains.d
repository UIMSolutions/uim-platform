/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.task_chains;

// import uim.platform.datasphere.domain.entities.task_chain;
// import uim.platform.datasphere.domain.ports.repositories.task_chains;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class ManageTaskChainsUseCase { // TODO: UIMUseCase {
  private TaskChainRepository repo;

  this(TaskChainRepository repo) {
    this.repo = repo;
  }

  CommandResult createTaskChain(CreateTaskChainRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Task chain name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    TaskChain tc;
    tc.initEntity(r.tenantId);
    tc.spaceId = r.spaceId;
    tc.name = r.name;
    tc.description = r.description;
    tc.status = TaskStatus.scheduled;
    tc.scheduleExpression = r.scheduleExpression;

    repo.save(tc);
    return CommandResult(true, tc.id.value, "");
  }

  TaskChain getTaskChain(SpaceId spaceId, TaskChainId id) {
    return repo.findById(spaceId, id);
  }

  TaskChain[] listTaskChains(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult patchTaskChain(PatchTaskChainRequest r) {
    auto chain = repo.findById(r.spaceId, r.taskChainId);
    if (chain.isNull)
      return CommandResult(false, "", "Task chain not found");

    import core.time : MonoTime;
    chain.updatedAt = currentTimestamp;

    repo.update(chain);
    return CommandResult(true, chain.id.value, "");
  }

  CommandResult deleteTaskChain(SpaceId spaceId, TaskChainId id) {
    auto chain = repo.findById(spaceId, id);
    if (chain.isNull)
      return CommandResult(false, "", "Task chain not found");

    repo.remove(chain);
    return CommandResult(true, chain.id.value, "");
  }
}
