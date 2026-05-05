module uim.platform.service.domain.ports.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface ITenantRepository(TEntity, TId) : IIdRepository!(TEntity, TId) {
  // PlatformRepostory

  bool exists(TEntity entity);
  size_t indexOf(TEntity entity);
  size_t countAll();
  TEntity[] findAll(size_t offset = 0, size_t limit = 0);
  void removeAll();

  void save(TEntity entity);
  void update(TEntity entity);
  void remove(TEntity entity);

  void updateAll(TEntity[] entities);
  void saveAll(TEntity[] entities);
  void removeAll(TEntity[] entities);

  // IIdRepository!(TEntity, TId) 

  bool existsById(TId id);
  TEntity findById(TId id);
  void removeById(TId id);

  bool existsAllById(TId[] ids);
  TEntity[] findAllById(TId[] ids, bool onlyExisting = true);
  void removeAllById(TId[] ids);

  void save(TEntity item);
  void update(TEntity item);
  void remove(TEntity item);

  void updateAll(TEntity[] items);
  void saveAll(TEntity[] items);
  void removeAll(TEntity[] items);

  //////////////////////
  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id);

  bool existsById(TenantId tenantId, TId id);
  TEntity findById(TenantId tenantId, TId id);
  void removeById(TenantId tenantId, TId id);

  bool existsAllById(TenantId tenantId, TId[] ids);
  TEntity[] findAllById(TenantId tenantId, TId[] ids);
  void removeAllById(TenantId tenantId, TId[] ids);

  bool isTenantEmpty(TenantId tenantId);
  void createTenant(TenantId tenantId);
  TenantId[] findAllTenants();
  bool existsByTenant(TenantId tenantId);
  size_t countByTenant(TenantId tenantId);
  TEntity[] filterByTenant(TEntity[] items, TenantId tenantId);
  TEntity[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0);
  void removeByTenant(TenantId tenantId);

}
