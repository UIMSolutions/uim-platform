/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic repository ports. Tenant repositories hold tenant wide
/// aggregates (datasets, rules, addresses); scoped repositories hold the
/// resources that live inside a dataset (key "<datasetId>~<id>").
module uim.platform.data_quality.ports.repositories.base;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

interface IDqTenantRepository(TEntity, TId) {
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

interface IDqScopedRepository(TEntity, TId) {
  /// All entities of the tenant (all datasets), ordered by creation time.
  TEntity[] findAll(TenantId t);
  /// Entities of one dataset; an empty dataset id means all datasets.
  TEntity[] findByDataset(TenantId t, DatasetId ds);
  TEntity findById(TenantId t, DatasetId ds, TId id);
  bool existsById(TenantId t, DatasetId ds, TId id);
  size_t countAll(TenantId t);
  size_t countByDataset(TenantId t, DatasetId ds);
  void save(TEntity entity);
  bool removeById(TenantId t, DatasetId ds, TId id);
  /// Remove every entity of a dataset; returns the number removed.
  size_t removeByDataset(TenantId t, DatasetId ds);
}
