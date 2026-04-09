/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.task_chains;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.task_chain;

interface TaskChainRepository {
  TaskChain findById(TaskChainId id, SpaceId spaceId);
  TaskChain[] findBySpace(SpaceId spaceId);
  TaskChain[] findByStatus(TaskStatus status, SpaceId spaceId);
  void save(TaskChain tc);
  void update(TaskChain tc);
  void remove(TaskChainId id, SpaceId spaceId);
  size_t countBySpace(SpaceId spaceId);
}
