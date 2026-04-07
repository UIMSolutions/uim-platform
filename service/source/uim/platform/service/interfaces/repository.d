 module uim.platform.service.interfaces.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IBaseRepository(TEntity, TId) {
  bool existsTenant(TenantId tenantId);
  TEntity findById(TId id);

  bool existsId(TId id);
  TEntity findById(TId id);

  void save(TEntity entity);
  void update(TEntity entity);
}