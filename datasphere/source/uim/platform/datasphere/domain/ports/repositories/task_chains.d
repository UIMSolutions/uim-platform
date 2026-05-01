/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.task_chains;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.task_chain;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface TaskChainRepository {
  TaskChain findById(SpaceId spaceId, TaskChainId id);
  TaskChain[] findBySpace(SpaceId spaceId);
  TaskChain[] findByStatus(SpaceId spaceId, TaskStatus status);
  void save(TaskChain tc);
  void update(TaskChain tc);
  void remove(SpaceId spaceId, TaskChainId id);
  size_t countBySpace(SpaceId spaceId);
}
