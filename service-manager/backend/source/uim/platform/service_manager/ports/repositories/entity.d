/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic tenant scoped repository port.
module uim.platform.service_manager.ports.repositories.entity;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IEntityRepository(TEntity, TId) {
  /// All entities of the tenant, ordered by creation time.
  TEntity[] findAll(TenantId tenantId);

  /// One entity, or TEntity.init (isNull) if it does not exist.
  TEntity findById(TenantId tenantId, TId id);

  bool existsById(TenantId tenantId, TId id);

  size_t countAll(TenantId tenantId);

  /// Insert or replace.
  void save(TEntity entity);

  /// Returns false if the entity did not exist.
  bool removeById(TenantId tenantId, TId id);
}
