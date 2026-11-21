/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository ports. Tenant repositories hold tenant wide
/// aggregates (resource groups, docker registry secrets); group
/// repositories hold everything that lives inside a resource group.
module uim.platform.ai_core.ports.repositories.base;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface ITenantWideRepository(TEntity, TId) {
  /// All entities of the tenant, ordered by creation time.
  TEntity[] findAll(TenantId t);
  /// One entity, or TEntity.init (isNull) if it does not exist.
  TEntity findById(TenantId t, TId id);
  bool existsById(TenantId t, TId id);
  size_t countAll(TenantId t);
  /// Insert or replace.
  void save(TEntity entity);
  /// Returns false if the entity did not exist.
  bool removeById(TenantId t, TId id);
}

interface IGroupRepository(TEntity, TId) {
  /// All entities of the tenant (all groups), ordered by creation time.
  TEntity[] findAll(TenantId t);
  /// Entities of one group; an empty group id means all groups.
  TEntity[] findByGroup(TenantId t, ResourceGroupId rg);
  TEntity findById(TenantId t, ResourceGroupId rg, TId id);
  bool existsById(TenantId t, ResourceGroupId rg, TId id);
  size_t countAll(TenantId t);
  void save(TEntity entity);
  bool removeById(TenantId t, ResourceGroupId rg, TId id);
  /// Remove every entity of a group; returns the number removed.
  size_t removeByGroup(TenantId t, ResourceGroupId rg);
}
