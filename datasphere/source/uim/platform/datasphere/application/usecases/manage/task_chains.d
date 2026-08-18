/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.task_chains;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageTaskChainsUseCase {
  protected ITaskChainRepository repo;

  this(ITaskChainRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTaskChain(CreateTaskChainRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Task chain name is required");
    if (r.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");

    auto tc = TaskChain(r.tenantId);
    tc.spaceId = r.spaceId;
    tc.name = r.name;
    tc.description = r.description;
    tc.status = TaskStatus.scheduled;
    tc.scheduleExpression = r.scheduleExpression;

    repo.save(tc);
    return UsecaseResult(true, tc.id.value, "");
  }

  TaskChain getTaskChain(TenantId tenantId, SpaceId spaceId, TaskChainId id) {
    return repo.findById(tenantId, spaceId, id);
  }

  TaskChain[] listTaskChains(TenantId tenantId, SpaceId spaceId) {
    return repo.findBySpace(tenantId, spaceId);
  }

  UsecaseResult patchTaskChain(PatchTaskChainRequest r) {
    auto chain = repo.findById(r.tenantId, r.spaceId, r.taskChainId);
    if (chain.isNull)
      return UsecaseResult(false, "", "Task chain not found");

    chain.updatedAt = currentTimestamp;

    repo.update(chain);
    return UsecaseResult(true, chain.id.value, "");
  }

  UsecaseResult deleteTaskChain(TenantId tenantId, SpaceId spaceId, TaskChainId id) {
    auto chain = repo.findById(tenantId, spaceId, id);
    if (chain.isNull)
      return UsecaseResult(false, "", "Task chain not found");

    repo.remove(chain);
    return UsecaseResult(true, chain.id.value, "");
  }
}
