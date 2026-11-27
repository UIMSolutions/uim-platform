/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository port of a tenant scoped aggregate.
module uim.platform.datasphere.ports.repositories.base;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IDspRepository(TEntity, TId) {
  /// All entities of the tenant, ordered by creation time.
  TEntity[] findAll(TenantId t);
  /// One entity, or TEntity.init (isNull) if it does not exist.
  TEntity findById(TenantId t, TId id);
  bool existsById(TenantId t, TId id);
  size_t countAll(TenantId t);
  /// Entities whose reference attribute (e.g. "spaceId") has the value,
  /// ordered by creation time. Filters before mapping (cheap).
  TEntity[] findByReference(TenantId t, string attribute, string value);
  size_t countByReference(TenantId t, string attribute, string value);
  /// Insert or replace.
  void save(TEntity entity);
  /// Returns false if the entity did not exist.
  bool removeById(TenantId t, TId id);
  /// Remove the entities whose reference attribute has the value; returns the count.
  size_t removeByReference(TenantId t, string attribute, string value);
}
