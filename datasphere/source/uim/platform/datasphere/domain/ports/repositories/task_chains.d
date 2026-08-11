/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.task_chains;

// import uim.platform.datasphere.domain.entities.task_chain;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface ITaskChainRepository : ITenantRepository!(TaskChain, TaskChainId) {
  TaskChain findById(TenantId tenantId, SpaceId spaceId, TaskChainId id);
  TaskChain[] findBySpace(TenantId tenantId, SpaceId spaceId);
  TaskChain[] findByStatus(TenantId tenantId, SpaceId spaceId, TaskStatus status);
  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
}